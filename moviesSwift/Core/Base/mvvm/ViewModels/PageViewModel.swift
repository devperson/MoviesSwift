import Foundation
import Resolver
import Observation

class PageViewModel: NavigatingBaseViewModel, IPageLifecycleAware
{
    private var appResumedEvent: AppResumedEvent!
    private var appPausedEvent: AppPausedEvent!
    
    override init(_ injectedService: InjectedService)
    {
        super.init(injectedService)

        self.BackCommand = AsyncCommand(OnBackCommand)
        appResumedEvent = GetEvent({ AppResumedEvent() })
        appPausedEvent = GetEvent({ AppPausedEvent() })
        appResumedEvent.Subscribe(InstanceId, ResumedFromBackground(_:))
        appPausedEvent.Subscribe(InstanceId, PausedToBackground(_:))
    }

    //Observable proerties
    @Published var Title: String = ""
    @Published var busyIndicator = false
    var BusyLoading: Bool
    {
        get { busyIndicator }
        set
        {
            busyIndicator = newValue
            if(busyIndicator)
            {
                injectedServices.BusyIndicatorService.Show(BusyText)
            }
            else
            {
                injectedServices.BusyIndicatorService.Close()
            }
        }
    }
    //Internal properties
    var InstanceId = UUID()
    var IsPageVisable: Bool = false
    var IsFirstTimeAppears: Bool = true
    var BusyText: String = "Loading..."
    var DisableDeviceBackButton: Bool = false
    //Commands
    var BackCommand: AsyncCommand!

    func OnAppearing()
    {
        LogVirtualBaseMethod(#function)
        IsPageVisable = true

        if IsFirstTimeAppears
        {
            IsFirstTimeAppears = false
            OnFirstTimeAppears()
        }
    }

    func OnAppeared()
    {
        LogVirtualBaseMethod(#function)
    }

    fileprivate func OnFirstTimeAppears()
    {
        LogVirtualBaseMethod(#function)
    }

    func OnDisappearing()
    {
        LogVirtualBaseMethod(#function)
        IsPageVisable = false
    }

    override func Destroy()
    {
        LogVirtualBaseMethod(#function)

        super.Destroy()

        appResumedEvent.Unsubscribe(InstanceId)
        appPausedEvent.Unsubscribe(InstanceId)
    }

    func ResumedFromBackground(_ arg: Any?)
    {
        LogVirtualBaseMethod(#function)
    }

    func PausedToBackground(_ arg: Any?)
    {
        LogVirtualBaseMethod(#function)
    }

    func OnBackCommand(_ arg: Any?) async
    {
        injectedServices.LoggingService.Log("\(String(describing: type(of: self))).OnBackCommand() (from base)")
        await NavigateBack()
    }

    func DoDeviceBackCommand()
    {
        Task
        {
            self.injectedServices.LoggingService.Log("\(String(describing: type(of: self))).DoDeviceBackCommand() (from base)")
            if self.DisableDeviceBackButton
            {
                self.injectedServices.LoggingService.Log("Cancel \(String(describing: type(of: self))).DoDeviceBackCommand(): Ignore back command because this page is set to cancel any device back button.")
            }
            else
            {
                await self.BackCommand.ExecuteAsync()
            }
        }
    }

    /// Runs an asynchronous action on a background thread while showing a loading indicator.
    /// - Parameters:
    ///   - asyncAction: The asynchronous work to perform in the background.
    ///   - onComplete: Optional callback executed on the main thread when the work finishes.
    ///
    /// This method:
    /// - Marks the ViewModel as busy (`BusyLoading = true`)
    /// - Executes `asyncAction` on a background scope (`BackgroundScope.await`)
    /// - Ensures the busy flag is cleared automatically using `defer`
    /// - Executes `onComplete` on the main thread (because the method is `@MainActor`)
    @MainActor
    func ShowLoading(_ asyncAction: @escaping () async -> Void, onComplete: ((Bool) -> Void)? = nil) async
    {
        LogMethodStart(#function)
        BusyLoading = true

        //await without return value
        await Task.detached
        {
            await asyncAction()   // running in background
        }.value
        
        defer
        {
            BusyLoading = false
        }//make sure it is set to false when done

        onComplete?(true)         // back on MainActor
    }

    /// Runs an asynchronous action on a background thread while showing a loading indicator,
    /// and returns its resulting value.
    /// - Parameters:
    ///   - asyncAction: The asynchronous work to perform in the background.
    ///   - setIsBusy: Whether to set `BusyLoading` before running the action.
    /// - Returns: The value produced by `asyncAction`.
    ///
    /// This method:
    /// - Marks the ViewModel as busy (if requested)
    /// - Executes `asyncAction` on a background scope
    /// - Returns the computed result
    /// - Ensures the busy flag is cleared even if the method exits early
    @MainActor
    func ShowLoadingWithResult<T>(_ asyncAction: @escaping () async -> T, setIsBusy: Bool = true) async -> T
    {
        LogMethodStart(#function)
        BusyLoading = setIsBusy
        // get value from asyncAction on background
        let result: T = await Task.detached
        {
            await asyncAction()
        }.value
        
        defer
        {
            BusyLoading = false
        }//make sure it is set to false when done

        return result
    }

    /// Runs an asynchronous throwing action on a background thread while showing a loading indicator,
    /// and returns its resulting value.
    /// - Parameters:
    ///   - asyncAction: The asynchronous work to perform in the background. This closure may throw.
    ///   - setIsBusy: Whether to mark the ViewModel as busy during the work.
    /// - Returns: The value produced by `asyncAction`.
    /// - Throws: Any error thrown by `asyncAction`.
    ///
    /// This method:
    /// - Sets `BusyLoading` (if requested)
    /// - Executes the throwing async work on a background scope
    /// - Propagates any errors thrown by `asyncAction`
    /// - Clears the busy flag via `defer`
    @MainActor
    func ShowLoadingWithResultThrow<T>(_ asyncAction: @escaping () async throws -> T, setIsBusy: Bool = true) async throws -> T
    {
        LogMethodStart(#function)
        BusyLoading = setIsBusy
       
        let result: T = try await Task.detached
        {
            try await asyncAction()  // run asyncAction on background
        }.value
        
        defer
        {
            BusyLoading = false
        }//make sure it is set to false when done

        return result
    }


    func HandleUIError(_ x: Error)
    {
        LogMethodStart(#function)

        var knownError = true

        switch x
        {

            case is CancellationError:
                injectedServices.LoggingService.LogWarning("Ignoring the CancellationError")
                return

            case let e as AuthExpiredException:
                injectedServices.LoggingService.LogWarning("Skip showing error popup for user because this error is handled in main view \(String(describing: type(of: e))): \(e.localizedDescription)")
                return

            case let e as HttpRequestException where e.StatusCode == HttpStatusCode.Unauthorized.rawValue:
                injectedServices.LoggingService.LogWarning("Skip showing error popup for user because this error is handled in main view \(String(describing: type(of: e))): \(e.localizedDescription)")
                return

            case is HttpConnectionException:
                injectedServices.SnackBarService.ShowError("It looks like there may be an issue with your connection. Please check your internet connection and try again.")

            case let e as HttpRequestException:
                if e.StatusCode == HttpStatusCode.ServiceUnavailable.rawValue
                {
                    injectedServices.SnackBarService.ShowError("The server is temporarily unavailable. Please try again later.")
                }
                else
                {
                    injectedServices.SnackBarService.ShowError("It seems server is not available, please try again later. (StatusCode - \(e.StatusCode)).")
                }

            case is ServerApiException:
                injectedServices.SnackBarService.ShowError("Internal Server Error. Please try again later.")

            default:
                knownError = false
                injectedServices.SnackBarService.ShowError("Oops something went wrong, please try again later.")
        }

        // logging
        if knownError
        {
            injectedServices.LoggingService.LogError(x)
        }
        else
        {
            injectedServices.LoggingService.TrackError(x)
        }
    }


    func GetEvent<T: IMessageEvent>(_ factory: () -> T) -> T
    {
        return injectedServices.EventAggregator.GetEvent(factory: factory)
    }

}
