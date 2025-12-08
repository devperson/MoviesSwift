import Foundation
import Resolver

@objcMembers class MoviesPageViewModel: AppPageViewModel
{
    let TAG: String = "MoviesPageViewModel:"
    static let SELECTED_ITEM = "SELECTED_ITEM"

    @LazyInjected var appLogExporter: IAppLogExporter
    @LazyInjected var movieService: IMovieService
    @LazyInjected var infrastructureServices: IInfrastructureServices

    var movieCellUpdatedEvent: MovieCellItemUpdatedEvent!
    var authErrorEvent: AuthErrorEvent!

    var MenuTappedCommand: AsyncCommand!
    var AddCommand: AsyncCommand!
    var ItemTappedCommand: AsyncCommand!
    var MovieItems: [MovieItemViewModel] = []

    let semaphoreAsync = AsyncSemaphore(value: 1)
    var loggingOut: Bool = false

    override init(_ injectedService: PageInjectedServices)
    {
        super.init(injectedService)

        self.MenuTappedCommand = AsyncCommand(OnMenuTappedCommand)
        self.AddCommand = AsyncCommand(OnAddCommand)
        self.ItemTappedCommand = AsyncCommand(OnItemTappedCommand)

        movieCellUpdatedEvent = GetEvent({ MovieCellItemUpdatedEvent() })
        authErrorEvent = GetEvent({ AuthErrorEvent() })
        movieCellUpdatedEvent.Subscribe(InstanceId, OnMovieCellItemUpdatedEvent)
        authErrorEvent.Subscribe(InstanceId, HandleAuthErrorEvent)
    }

    override func Initialize(_ parameters: INavigationParameters)
    {
        super.Initialize(parameters)

        Task
        {
            do
            {
                try await self.infrastructureServices.Start()
                await self.LoadData(getFromServer: false, showError: false)
            }
            catch
            {
                self.Services.LoggingService.TrackError(error)
            }
        }
    }

    override func OnNavigatedTo(_ parameters: INavigationParameters)
    {
        super.OnNavigatedTo(parameters)
        if parameters.ContainsKey(AddEditMoviePageViewModel.NEW_ITEM)
        {
            let newProduct: MovieItemViewModel = GetParameter(parameters, key: AddEditMoviePageViewModel.NEW_ITEM)!
            MovieItems.insert(newProduct, at: 0)
        }
        else if parameters.ContainsKey(AddEditMoviePageViewModel.REMOVE_ITEM)
        {
            let removedItem: MovieItemViewModel = GetParameter(parameters, key: AddEditMoviePageViewModel.REMOVE_ITEM)!
            MovieItems.removeAll(where: { $0.Id == removedItem.Id })
        }
    }

    override func PausedToBackground(_ arg: Any?)
    {
        super.PausedToBackground(arg)
        Task.detached
        {
            await self.infrastructureServices.Pause()
        }
    }

    override func ResumedFromBackground(_ arg: Any?)
    {
        super.ResumedFromBackground(arg)
        Task.detached
        {
            await self.infrastructureServices.Resume()
        }
    }

    override func Destroy()
    {
        super.Destroy()
        self.movieCellUpdatedEvent.Unsubscribe(InstanceId)
        self.authErrorEvent.Unsubscribe(InstanceId)
        Task
        {
            await self.infrastructureServices.Stop()
        }
    }

    func OnAddCommand(_ arg: Any?) async
    {
        LogMethodStart(#function, arg)
        await Navigate(NameOf(AddEditMoviePageViewModel.self))
    }

    func OnItemTappedCommand(_ arg: Any?) async
    {
        LogMethodStart(#function, arg)
        guard let item = arg as? MovieItemViewModel
        else
        {
            return
        }
        await Navigate(NameOf(MovieDetailPageViewModel.self), NavigationParameters().With(MoviesPageViewModel.SELECTED_ITEM, item))
    }

    func OnMenuTappedCommand(_ arg: Any?) async
    {
        LogMethodStart(#function, arg)
        guard let item = arg as? MenuItem
        else
        {
            return
        }
        if item.ItemType == .ShareLogs
        {
            let res = await appLogExporter.ShareLogs()
            if !res.Success
            {
                let error = res.Exception?.localizedDescription
                injectedServices.SnackBarService.ShowError("Share file failed. \(error ?? "")")
            }
        }
        else if item.ItemType == .Logout
        {
            let confirmed = await Services.AlertDialogService.ConfirmAlert(title: "Confirm Action", message: "Are you sure want to log out?", buttons: ["Yes", "No"])
            if confirmed
            {
                await Navigate("/\(NameOf(LoginPageViewModel.self))", NavigationParameters())
            }
        }
    }

    func OnMovieCellItemUpdatedEvent(_ model: Any?)
    {
        LogMethodStart(#function, model as Any)
        Task.detached
        {
            guard let movieItem = model as? MovieItemViewModel
            else
            {
                return
            }
            if let oldItem = self.MovieItems.first(where: { $0.Id == movieItem.Id })
            {
                if let index = self.MovieItems.firstIndex(of: oldItem)
                {
                    self.MovieItems[index] = movieItem
                }
            }
        }
    }

    override func OnRefreshCommand(_ arg: Any?) async
    {
        LogMethodStart(#function)
        IsRefreshing = true
        await LoadData(getFromServer: true, showError: true)
        IsRefreshing = false
    }

    private func SetMovieList(_ list: [MovieDto])
    {
        let convertedList = list.map
        {
            MovieItemViewModel($0)
        }
        Services.LoggingService.Log("\(TAG): setting data to MovieItems property from OnRefreshCommand result: \(list.ToDebugString())")
        MovieItems = convertedList
    }

    func HandleAuthErrorEvent(_ arg: Any?)
    {
        LogMethodStart(#function)


        Task.detached
        {
            await self.semaphoreAsync.WaitAsync()
            if self.loggingOut
            {
                self.Services.LoggingService.LogWarning("Skip HandleAuthErrorEvent() because another thread is handled it")
                await self.semaphoreAsync.Release()
                return
            }
            self.loggingOut = true
            
            //make sure we are in root page before navigating to login page
            if let currentVm = self.GetCurrentPageViewModel(), !(currentVm is MoviesPageViewModel)
            {
                await currentVm.NavigateToRoot()
            }
            
            await self.Navigate("../\(NameOf(LoginPageViewModel.self))", NavigationParameters())
            await self.semaphoreAsync.Release()
        }
    }

    func LoadData(getFromServer: Bool = false, showError: Bool = false) async
    {
        LogMethodStart(#function, getFromServer)
        
        let result = await ShowLoadingWithResult(
            {
                await self.movieService.GetListAsync(remoteList: getFromServer)
            }, setIsBusy: getFromServer)
        
        if result.Success
        {
            SetMovieList(result.ValueOrThrow)
        }
        else
        {
            if let ex = result.Exception
            {
                if showError
                {
                    HandleUIError(ex)
                }
                else
                {
                    loggingService.TrackError(ex as NSError)
                }
            }
        }
    }
}

class MenuItem: Equatable
{
    var Title: String = ""
    var Icon: String = ""
    var ItemType: MenuType = .None

    static func ==(lhs: MenuItem, rhs: MenuItem) -> Bool
    {
        return lhs.Title == rhs.Title && lhs.Icon == rhs.Icon && lhs.ItemType == rhs.ItemType
    }
}

enum MenuType
{
    case None, Logout, ShareLogs
}
