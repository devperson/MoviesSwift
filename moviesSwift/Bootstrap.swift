import Resolver



class Bootstrap
{
    func RegisterTypes(_ navService: IPageNavigationService, _ errorTrackingService: IErrorTrackingService)
    {
        BaseImplRegistrar.RegisterTypes()
        AppDomainRegistrar.RegisterTypes()
        Resolver.RegisterAppImpl(navService, errorTrackingService)
        
       
        //Register pages, viewmodels mapping
        NavRegistrar.RegisterPageForNavigation({ LoginPage() }, { LoginPageViewModel(self.Resolve()) })
        NavRegistrar.RegisterPageForNavigation({ MoviesPage() }, { MoviesPageViewModel(self.Resolve()) })
        NavRegistrar.RegisterPageForNavigation({ MovieDetailPage() }, { MovieDetailPageViewModel(self.Resolve()) })
        NavRegistrar.RegisterPageForNavigation({ AddEditMoviePage() }, { AddEditMoviePageViewModel(self.Resolve()) })
    }
    
    func Resolve<T>() -> T
    {
        return ContainerLocator.Resolve()
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
