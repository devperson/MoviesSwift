import Foundation

class NavigatingBaseViewModel: BaseViewModel, INavigationAware
{
    var injectedServices: InjectedService

    init(_ injectedServices: InjectedService)
    {
        self.injectedServices = injectedServices
        super.init()
    }

    var CanGoBack: Bool
    {
        return injectedServices.NavigationService.CanNavigateBack
    }

    func OnNavigatedFrom(_ parameters: INavigationParameters)
    {
        LogVirtualBaseMethod(#function)
    }

    func OnNavigatedTo(_ parameters: INavigationParameters)
    {
        LogVirtualBaseMethod(#function)
    }

    func GetCurrentPageViewModel() -> NavigatingBaseViewModel?
    {
        LogVirtualBaseMethod(#function)
        return injectedServices.NavigationService.GetCurrentPageModel()
    }

    func Navigate(_ name: String, _ parameters: INavigationParameters? = nil, useModalNavigation: Bool = false, animated: Bool = true, wrapIntoNav: Bool = false) async
    {
        do
        {
            LogVirtualBaseMethod("Navigate(name=\(name))")
            try await injectedServices.NavigationService.Navigate(name, parameters: parameters, useModalNavigation: useModalNavigation, animated: animated, wrapIntoNav: wrapIntoNav)
        }
        catch
        {
            injectedServices.LoggingService.TrackError(error)
        }
        
        
    }

    func NavigateToRoot(_ parameters: INavigationParameters? = nil) async
    {
        do
        {
            LogVirtualBaseMethod(#function)
            try await injectedServices.NavigationService.NavigateToRoot(parameters: parameters)
        }
        catch
        {
            injectedServices.LoggingService.TrackError(error)
        }
    }

    func SkipAndNavigate(_ skipCount: Int, route: String, parameters: INavigationParameters? = nil) async
    {
        LogVirtualBaseMethod("SkipAndNavigate(skipCount=\(skipCount), route=\(route))")
        var skip = ""
        for _ in 0..<skipCount
        {
            skip += "../"
        }
        let newRoute = "\(skipCount)\(route)"
        await Navigate(newRoute, parameters)
    }

    func NavigateAndMakeRoot(_ name: String, parameters: INavigationParameters? = nil, useModalNavigation: Bool = false, animated: Bool = true) async
    {
        LogVirtualBaseMethod("NavigateAndMakeRoot(name=\(name))")
        let newRoot = "/\(name)"
        await Navigate(newRoot, parameters, useModalNavigation: useModalNavigation, animated: animated)
    }

    func NavigateBack(_ parameters: INavigationParameters? = nil) async
    {
        LogVirtualBaseMethod(#function)
        await Navigate("../", parameters)
    }

    func BackToRootAndNavigate(_ name: String, parameters: INavigationParameters? = nil) async
    {
        LogVirtualBaseMethod("BackToRootAndNavigate(name=\(name))")
        let navStack = injectedServices.NavigationService.GetNavStackModels().map
        {
            String(describing: $0).components(separatedBy: ".").last ?? ""
        }

        let currentNavStack: String
        if navStack.count > 1
        {
            currentNavStack = navStack.joined(separator: "/")
        }
        else
        {
            currentNavStack = navStack.first ?? ""
        }

        let popCount = navStack.count - 1
        let popPageUri = popCount > 0 ? String(repeating: "../", count: popCount) : ""
        let resultUri = "\(popPageUri)\(name)"

        injectedServices.LoggingService.Log("BackToRootAndNavigate(): Current navigation stack: /\(currentNavStack), pop count: \(popCount), resultUri: \(resultUri)")

        await Navigate(resultUri, parameters)
    }

    func GetParameter<T>(_ parameters: INavigationParameters, key: String) -> T?
    {
        LogVirtualBaseMethod("GetParameter(key = \(key))")
        if parameters.ContainsKey(key)
        {
            return parameters.GetValue(key)
        }
        else
        {
            return nil
        }
    }

    func GetParameter<T>(_ parameters: INavigationParameters, key: String, setter: (T?) -> Void)
    {
        LogVirtualBaseMethod("GetParameter(key = \(key), setter())")
        if parameters.ContainsKey(key)
        {
            let value: T? = parameters.GetValue(key)
            setter(value)
        }
    }

    func LogVirtualBaseMethod(_ methodName: String)
    {
        injectedServices.LoggingService.Log("\(String(describing: type(of: self))).\(methodName)() (from base)")
    }
}
