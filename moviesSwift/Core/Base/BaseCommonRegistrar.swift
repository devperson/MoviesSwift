import Resolver
import Foundation


class BaseRegistrar
{
    static func RegisterTypes()
    {
        Resolver.RegisterBaseTypes()
    }
    
    static func RegisterCommon()
    {
        Resolver.RegisterBaseCommon()
    }
    
    static func RegisterBaseImpl()
    {
        Resolver.RegisterBaseImpl()
    }
}

extension Resolver
{
    static func RegisterBaseTypes()
    {
        RegisterBaseCommon()
        RegisterBaseImpl()
    }
    
    static func RegisterBaseCommon()
    {
        //singleton - .application
        //every time new - .unique
        register { AppLoggingService() as ILoggingService }.scope(.application)
        register { SimpleMessageCenter() as IMessagesCenter }.scope(.application)
        register { VersionTrackingImplementation() as IVersionTracking }.scope(.application)
        register { AppLogExporter() as IAppLogExporter }.scope(.application)
    }
    
    static func RegisterBaseImpl()
    {
        //infrastructures
        register { RestClient() as IRestClient }.scope(.application)
        //register { SimpleMessageCenter() as IMessagesCenter }.scope(.application)
        register { RequestQueueList() }.scope(.application)
        register { AuthTokenService() as IAuthTokenService }.scope(.application)
        
//        register { DroidAppInfoImplementation() as IAppInfo }.scope(.application)
//        register { SimpleMessageCenter() as IMessagesCenter }.scope(.application)
//        register { VersionTrackingImplementation() as IVersionTracking }.scope(.application)
//        register { AppLogExporter() as IAppLogExporter }.scope(.application)
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

