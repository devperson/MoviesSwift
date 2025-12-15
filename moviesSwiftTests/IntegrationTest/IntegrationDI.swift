import XCTest
import Resolver
import Mockable

@testable import moviesSwift


class IntegrationDI: XCTestCase
{
    override func setUpWithError() throws
    {
        //register types
        Resolver.RegisterIntegrationServiceTypes()
        
        // NOTE: If we don't disable DisableDoubleClickCheck for commands,
        // any second or third execution that occurs within 1 second will be ignored.
        // In unit/automated tests, commands often run within milliseconds of each other,
        // so the debounce logic would incorrectly suppress those calls.
        // Therefore, we need to disable this check during tests.
        AsyncCommand.DisableDoubleClickCheck = true
        //set logging for some utils
        let loggingService: ILoggingService = ContainerLocator.Resolve()
        AsyncCommand.loggingService = loggingService
    }

    override func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension Resolver
{
    static func RegisterIntegrationServiceTypes()
    {
        //register real services
        BaseImplRegistrar.RegisterTypes()
        AppDomainRegistrar.RegisterTypes()
        //to not specify a return value for all mocked methods - set it to relaxed mode in global scope
        //or set it in the constructor of mock class like MockSample(policy: [.relaxedOptional, .relaxedVoid])
        //https://github.com/Kolos65/Mockable?tab=readme-ov-file#relaxed-mode
        MockerPolicy.default = .relaxed
        //register types
        //register { MockInfrastructureServicesGen() as IInfrastructureServices }.scope(.application)
        register { CustomErrorTrackingService() as IErrorTrackingService }.scope(.application)
        register { CustomPageNavigationService() as IPageNavigationService }.scope(.application)
        register { ConstantImpl() as IConstant }.scope(.application)
        
        //register viewmodels
        register { PageInjectedServices() }.scope(.application)
        //we register under base type because we need to resolve it as {type: PageViewModel, name: MoviesPageViewModel}
        //this is Resolver restriction
        register(PageViewModel.self, name: Resolver.Name("MoviesPageViewModel")) { MoviesPageViewModel(resolve())
        }.scope(.unique)
        register(PageViewModel.self, name: Resolver.Name("AddEditMoviePageViewModel")) { AddEditMoviePageViewModel(resolve())
        }.scope(.unique)
        
    }
}

