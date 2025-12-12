import SwiftUI
import Resolver

@main struct iOSApp: App
{
    init()
    {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil
        {
            // Normal app launch → register real DI here
            let appErrorTracking = iOSErrorTrackingService()
            let navigationService = Sui_PageNavigationService.shared
            let bootstrap = Bootstrap()
            bootstrap.RegisterTypes(navigationService, appErrorTracking)
            //set logging for some utils
            let loggingService: ILoggingService = ContainerLocator.Resolve()
            AsyncCommand.loggingService = loggingService
            //navigate to root page
            bootstrap.NavigateToPage(navigationService)
        }
        else
        {
            // Running under unit tests → skip or register mocks/stubs
            print("Running under tests — skipping real DI registration")
        }
    }
    
    var body: some Scene
    {
        WindowGroup
        {
            RootView()
        }
    }
}

