import Foundation
import Resolver

@Observable
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

    var InstanceId = UUID()
    var BackCommand: AsyncCommand!
    var Title: String = ""
    var IsPageVisable: Bool = false
    var IsFirstTimeAppears: Bool = true
    var BusyLoading: Bool = false
    var DisableDeviceBackButton: Bool = false
    
    let BackgroundScope = AsyncScope
    { block in

        try await Task.detached
        {
            try await block()
        }
        .value
    }

    let MainThreadScope = AsyncScope
    { block in

        try await AsyncScope.runOnMain
        {
            try await block()
        }
    }

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
        MainThreadScope.run
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
    @MainActor func ShowLoading(_ asyncAction: @escaping () async -> Void, onComplete: ((Bool) -> Void)? = nil) async
    {
        LogMethodStart(#function)
        BusyLoading = true
        defer
        {
            BusyLoading = false
        }//make sure it is set to false when done

        //await without return value
        await BackgroundScope.await
        {
            await asyncAction()   // background automatically
        }

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
    @MainActor func ShowLoadingWithResult<T>(_ asyncAction: @escaping () async -> T, setIsBusy: Bool = true) async throws -> T
    {
        LogMethodStart(#function)
        BusyLoading = setIsBusy
        defer
        {
            BusyLoading = false
        }//make sure it is set to false when done

        // get value from asyncAction on background
        let result: T = await BackgroundScope.await
        {
            await asyncAction()
        }

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
    @MainActor func ShowLoadingWithResultThrow<T>(_ asyncAction: @escaping () async throws -> T, setIsBusy: Bool = true) async throws -> T
    {
        LogMethodStart(#function)
        BusyLoading = setIsBusy
        defer
        {
            BusyLoading = false
        }//make sure it is set to false when done

        // run asyncAction on background
        let result: T = try await BackgroundScope.await
        {
            try await asyncAction()
        }

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

            case let e as HttpRequestException where e.statusCode == HttpStatusCode.Unauthorized.rawValue:
                injectedServices.LoggingService.LogWarning("Skip showing error popup for user because this error is handled in main view \(String(describing: type(of: e))): \(e.localizedDescription)")
                return

            case is HttpConnectionException:
                injectedServices.SnackBarService.ShowError("It looks like there may be an issue with your connection. Please check your internet connection and try again.")

            case let e as HttpRequestException:
                if e.statusCode == HttpStatusCode.ServiceUnavailable.rawValue
                {
                    injectedServices.SnackBarService.ShowError("The server is temporarily unavailable. Please try again later.")
                }
                else
                {
                    injectedServices.SnackBarService.ShowError("It seems server is not available, please try again later. (StatusCode - \(e.statusCode)).")
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

struct AsyncScope
{
    let executor: (@escaping () async throws -> Any?) async throws -> Any?

    // MARK: Void, non-throwing
    func await(_ block: @escaping () async -> Void) async
    {
        _ = try? await executor
        {
            await block()
            return nil       // <-- normalize Void to nil
        }
    }

    // MARK: Void, throwing
    func await(_ block: @escaping () async throws -> Void) async throws
    {
        _ = try await executor
        {
            try await block()
            return nil
        }
    }

    // MARK: Non-Void, non-throwing
    func await<T>(_ block: @escaping () async -> T) async -> T
    {
        let result = try? await executor
        {
            return await block()
        } as? T
        return result!
    }

    // MARK: Non-Void, throwing
    func await<T>(_ block: @escaping () async throws -> T) async throws -> T
    {
        let result = try await executor
        {
            return try await block()
        } as? T
        return result!
    }

    @MainActor
    static func runOnMain<T>(_ block: @escaping () async throws -> T) async throws -> T
    {
        try await Task
        { @MainActor in
            try await block()
        }
        .value
    }
}

extension AsyncScope
{

    // MARK: Non-async entry — fire & forget
    func run(_ block: @escaping () async -> Void)
    {
        Task
        {
            await self.await(block)
        }
    }

    // MARK: Non-async entry — fire & forget but can throw
    func run(_ block: @escaping () async throws -> Void)
    {
        Task
        {
            try? await self.await(block)
        }
    }

    // MARK: Non-async entry with return value (ignored)
    func run<T>(_ block: @escaping () async -> T)
    {
        Task
        {
            _ = await self.await(block)
        }
    }

    // MARK: Non-async entry with return & throwing (ignored)
    func run<T>(_ block: @escaping () async throws -> T)
    {
        Task
        {
            _ = try? await self.await(block)
        }
    }
}
