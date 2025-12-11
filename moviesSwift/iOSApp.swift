import SwiftUI
import Resolver

@main struct iOSApp: App
{
    init()
    {
        let appErrorTracking = iOSErrorTrackingService()
        let navigationService = Sui_PageNavigationService.shared
        let bootstrap = Bootstrap()
        bootstrap.RegisterTypes(navigationService, appErrorTracking)
        bootstrap.NavigateToPage(navigationService)
    }
    
    var body: some Scene
    {
        WindowGroup
        {
            RootView()
        }
    }
}

//extension Resolver: @retroactive ResolverRegistering //disabling warning with @retroactive
//{
//    public static func registerAllServices()
//    {
//        print("🔥 Resolver registerAllServices called!")
//        
//        let appErrorTracking = iOSErrorTrackingService()
//        let navigationService = Sui_PageNavigationService.shared
//        let bootstrap = Bootstrap()
//        bootstrap.RegisterTypes(navigationService, appErrorTracking)
//        bootstrap.NavigateToPage(navigationService)
//    }
//}
