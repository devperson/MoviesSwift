import Foundation
import Resolver

@objcMembers
class MoviesPageViewModel: AppPageViewModel {
    let TAG: String = "MoviesPageViewModel:"
    static let SELECTED_ITEM = "SELECTED_ITEM"

    @LazyInjected var appLogExporter: IAppLogExporter
    @LazyInjected var movieService: IMovieService
    @LazyInjected var infrastructureServices: IInfrastructureServices

    var movieCellUpdatedEvent: MovieCellItemUpdatedEvent
    var authErrorEvent: AuthErrorEvent

    var MenuTappedCommand: AsyncCommand!
    var AddCommand: AsyncCommand!
    var ItemTappedCommand: AsyncCommand!
    var MovieItems: [MovieItemViewModel] = []

    var semaphoreAuthError = DispatchSemaphore(value: 1)
    var loggingOut: Bool = false

    override init(_ injectedService: PageInjectedServices) {
       

        super.init(injectedService)
        
        self.MenuTappedCommand = AsyncCommand(OnMenuTappedCommand)
        self.AddCommand = AsyncCommand(OnAddCommand)
        self.ItemTappedCommand = AsyncCommand(OnItemTappedCommand)

        movieCellUpdatedEvent = GetEvent({ MovieCellItemUpdatedEvent() })
        authErrorEvent = GetEvent({ AuthErrorEvent() })
        movieCellUpdatedEvent.Subscribe(InstanceId, OnMovieCellItemUpdatedEvent)
        authErrorEvent.Subscribe(InstanceId, HandleAuthErrorEvent)
    }

    override func Initialize(_ parameters: INavigationParameters) {
        super.Initialize(parameters)

        Task.detached {
            do {
                try await self.infrastructureServices.Start()
                await self.LoadData(getFromServer: false, showError: false)
            } catch {
                // handle error
            }
        }
    }

    override func OnNavigatedTo(_ parameters: INavigationParameters) {
        super.OnNavigatedTo(parameters)
        do {
            if parameters.ContainsKey(AddEditMoviePageViewModel.NEW_ITEM) {
                if let newProduct = GetParameter(parameters, key: AddEditMoviePageViewModel.NEW_ITEM) as? MovieItemViewModel {
                    MovieItems.Add(0, newProduct)
                }
            } else if parameters.ContainsKey(AddEditMoviePageViewModel.REMOVE_ITEM) {
                if let removedItem = GetParameter(parameters, key: AddEditMoviePageViewModel.REMOVE_ITEM) as? MovieItemViewModel {
                    MovieItems.Remove(removedItem)
                }
            }
        } catch {
            Services.LoggingService.TrackError(error as NSError)
        }
    }

    func PausedToBackground(_ arg: Any?) {
        Task.detached {
            do {
                try await self.infrastructureServices.Pause()
            } catch {
                Services.LoggingService.TrackError(error as NSError)
            }
        }
    }

    func ResumedFromBackground(_ arg: Any?) {
        Task.detached {
            do {
                try await self.infrastructureServices.Resume()
            } catch {
                Services.LoggingService.TrackError(error as NSError)
            }
        }
    }

    override func Destroy() {
        Task {
            self.movieCellUpdatedEvent?.Unsubscribe(OnMovieCellItemUpdatedEvent(_:))
            self.authErrorEvent?.Unsubscribe(HandleAuthErrorEvent(_:))
            try await self.infrastructureServices.Stop()
            super.Destroy()
        }
    }

    func OnAddCommand(_ arg: Any?) async {
        do {
            LogMethodStart("OnAddCommand")
            await Navigate("AddEditMoviePageViewModel")
        } catch {
            HandleUIError(error)
        }
    }

    func OnItemTappedCommand(_ arg: Any?) async {
        do {
            LogMethodStart("OnItemTappedCommand", arg as Any)
            guard let item = arg as? MovieItemViewModel else { return }
            await Navigate("MovieDetailPageViewModel", NavigationParameters())
        } catch {
            HandleUIError(error)
        }
    }

    func OnMenuTappedCommand(_ arg: Any?) async {
        do {
            LogMethodStart("OnMenuTappedCommand", arg as Any)
            guard let item = arg as? MenuItem else { return }
            if item.Type == .ShareLogs {
                let res = await appLogExporter.ShareLogs()
                if !res.Success {
                    let error = res.Exception?.localizedDescription
                    injectedServices.SnackBarService.ShowError("Share file failed. \(error ?? "")")
                }
            } else if item.Type == .Logout {
                let confirmed = Services.AlertDialogService.ConfirmAlert("Confirm Action", "Are you sure want to log out?", "Yes", "No")
                if confirmed {
                    await Navigate("/LoginPageViewModel", NavigationParameters())
                }
            }
        } catch {
            HandleUIError(error)
        }
    }

    func OnMovieCellItemUpdatedEvent(_ model: Any?) {
        LogMethodStart("OnMovieCellItemUpdatedEvent", model as Any)
        Task.detached {
            do {
                guard let movieItem = model as? MovieItemViewModel else { return }
                if let oldItem = self.MovieItems.Items.first(where: { $0.Id == movieItem.Id }) {
                    if let index = self.MovieItems.Items.firstIndex(of: oldItem) {
                        if index >= 0 {
                            self.MovieItems.Replace(index, movieItem)
                        }
                    }
                }
            } catch {
                Services.LoggingService.TrackError(error as NSError)
            }
        }
    }

    func OnRefreshCommand(_ arg: Any?) async {
        LogMethodStart("OnRefreshCommand")
        do {
            IsRefreshing = true
            await LoadData(getFromServer: true, showError: true)
        } catch {
            Services.LoggingService.TrackError(error as NSError)
        }
        IsRefreshing = false
    }

    private func SetMovieList(_ list: [MovieDto]) {
        let convertedList = list.map { MovieItemViewModel($0) }
        Services.LoggingService.Log("")
        MovieItems = ObservableCollection(convertedList)
    }

    func HandleAuthErrorEvent(_ arg: Any?) {
        LogMethodStart("HandleAuthErrorEvent")

        Task.detached {
            do {
                self.semaphoreAuthError.wait()
                if self.loggingOut {
                    Services.LoggingService.LogWarning("Skip HandleAuthErrorEvent() because another thread is handling it")
                    self.semaphoreAuthError.signal()
                    return
                }
                self.loggingOut = true
                if let currentVm = self.GetCurrentPageViewModel(), !(currentVm is MoviesPageViewModel) {
                    currentVm.NavigateToRoot()
                }
                await self.Navigate("../LoginPageViewModel", NavigationParameters())
                self.semaphoreAuthError.signal()
            } catch {
                Services.LoggingService.TrackError(error as NSError)
                self.semaphoreAuthError.signal()
            }
        }
    }

    func LoadData(getFromServer: Bool = false, showError: Bool = false) async {
        LogMethodStart("LoadData", getFromServer)

        let result = await ShowLoadingWithResult({ try await movieService.GetListAsync(remoteList: getFromServer) }, setIsBusy: getFromServer)
        if result.Success {
            SetMovieList(result.ValueOrThrow)
        } else {
            if let ex = result.Exception {
                if showError {
                    HandleUIError(ex)
                } else {
                    loggingService.TrackError(ex as NSError)
                }
            }
        }
    }
}

class MenuItem: Equatable {
    var Title: String = ""
    var Icon: String = ""
    var Type: MenuType = .None

    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool {
        return lhs.Title == rhs.Title && lhs.Icon == rhs.Icon && lhs.Type == rhs.Type
    }
}

enum MenuType {
    case None, Logout, ShareLogs
}
