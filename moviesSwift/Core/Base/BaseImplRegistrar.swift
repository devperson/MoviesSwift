import Resolver
import Foundation


class BaseImplRegistrar
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
        
        //Platform
        register { IOSAppInfoImplementation() as IAppInfo }.scope(.application)
        register { iOSPreferencesImplementation() as IPreferences }.scope(.application)
        register { IOSBrowserImplementation() as IBrowser }.scope(.application)
        register { iOSDeviceInfoImplementation() as IDeviceInfo }.scope(.application)
        register { iOSDeviceThreadService() as IDeviceThreadService }.scope(.application)
        register { iOSDisplayImplementation() as IDisplay }.scope(.application)
        register { iOSDirectoryService() as IDirectoryService }.scope(.application)
        //register { EmailImpl() as IEmail }.scope(.application)
        register { iOSShareImplementation() as IShare }.scope(.application)
        register { iOSZipService() as IZipService }.scope(.application)
        register { Sui_SnackbarBarService() as ISnackbarService }.scope(.application)
        register { Sui_AlertDialogService.shared as IAlertDialogService }.scope(.application)
        register { Sui_MediaPickerService() as IMediaPickerService }.scope(.application)
        register { iOSConsoleOutput() as IPlatformOutput }.scope(.application)
        register { iOSFileLogger() as IFileLogger }.scope(.application)
        register { iOSErrorTrackingService() as IErrorTrackingService }.scope(.application)        
    }
    

    
    
    
}

