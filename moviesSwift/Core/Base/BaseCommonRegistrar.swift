import Resolver
import Foundation


class BaseRegistrar
{
    static func RegisterTypes()
    {
        Resolver.RegisterBaseTypes()
    }
}

extension Resolver
{
    static func RegisterBaseTypes()
    {
        //singleton - .application
        //every time new - .unique
        //regiter common
        register { AppLoggingService() as ILoggingService }.scope(.application)
        register { SimpleMessageCenter() as IMessagesCenter }.scope(.application)
        register { VersionTrackingImplementation() as IVersionTracking }.scope(.application)
        register { AppLogExporter() as IAppLogExporter }.scope(.application)
        
        //infrastructures
        register { RestClient() as IRestClient }.scope(.application)
        //register { SimpleMessageCenter() as IMessagesCenter }.scope(.application)
        register { RequestQueueList() }.scope(.application)
        register { AuthTokenService() as IAuthTokenService }.scope(.application)
        
        //register platform
    }

//    val baseDroidModule = module()
//                   {
//                       //Essentials
//                       single<IAppInfo> { DroidAppInfoImplementation() }
//                       single<IBrowser> { DroidBrowserImplementation() }
//                       single<IDeviceInfo> { DroidDeviceInfoImplementation() }
//                       single<IDeviceThreadService> { DroidDeviceThreadService() }
//                       single<IDisplay> { DroidDisplayImplementation() }
//                       single<IDirectoryService> { DroidDirectoryService() }
//                       single<IEmail> { DroidEmailImplementation() }
//                       single<IMediaPickerService> { mediaPickerService }
//                       single<IPreferences> { DroidPreferencesImplementation() }
//                       single<IShare> { DroidShareImplementation() }
//
//                       //PlatformServices
//                       single<IZipService> { DroidZipService() }
//
//                       //UI
//                       single<IAlertDialogService> { DroidAlertDialogService() }
//                       single<ISnackbarService> { DroidSnackbarService() }
//
//                       //Diagnostic
//                       single<IFileLogger> { DroidLogbackFileLogger() }
//                       single<IPlatformOutput> { DroidConsoleOutput() }
//                   }
    
    
    
}

