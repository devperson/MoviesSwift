import Resolver



class Bootstrap
{
    func RegisterTypes(_ navService: IPageNavigationService, _ errorTrackingService: IErrorTrackingService)
    {
        BaseImplRegistrar.RegisterTypes()
        AppDomainRegistrar.RegisterTypes()
        Resolver.RegisterAppImpl(navService, errorTrackingService)
        
        
        //Register pages, viewmodels mapping
        
        let pageService: PageInjectedServices = ContainerLocator.Resolve()
        NavRegistrar.RegisterPageForNavigation({ LoginPage() }, { LoginPageViewModel(pageService) })
        NavRegistrar.RegisterPageForNavigation({ MoviesPage() }, { MoviesPageViewModel(pageService) })
        NavRegistrar.RegisterPageForNavigation({ MovieDetailPage() }, { MovieDetailPageViewModel(pageService) })
        NavRegistrar.RegisterPageForNavigation({ AddEditMoviePage() }, { AddEditMoviePageViewModel(pageService) })
        
//        let logging: ILoggingService = ContainerLocator.Resolve()
//        let busyIndic: IBusyIndicatorService = ContainerLocator.Resolve()
    }
    
    func NavigateToPage(_ navigationService: IPageNavigationService)
    {
        do
        {
            let nav = navigationService as! Sui_PageNavigationService
            let preferences: IPreferences = ContainerLocator.Resolve()
            let isLoggedIn = try preferences.Get(LoginPageViewModel.IsLoggedIn, defaultValue: false)
            
            if isLoggedIn
            {
                let mainPage = String(describing: MoviesPageViewModel.self)
                nav.OnNavigateFirstTime(mainPage, NavigationParameters())
            }
            else
            {
                let loginPage = String(describing: LoginPageViewModel.self)
                nav.OnNavigateFirstTime(loginPage, NavigationParameters())
            }
        }
        catch
        {
            let loggingService: ILoggingService = ContainerLocator.Resolve()
            loggingService.TrackError(error)
        }
    }
}

extension Resolver
{
    static func RegisterAppImpl(_ navService: IPageNavigationService, _ errorTrackingService: IErrorTrackingService)
    {    
        register { ConstantImpl() as IConstant }.scope(.application)
        register { navService as IPageNavigationService }.scope(.application)
        register { errorTrackingService as IErrorTrackingService }.scope(.application)
        let services = PageInjectedServices()
        register { services as PageInjectedServices }.scope(.application)
        
    }
}
