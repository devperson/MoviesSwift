import XCTest
import Resolver
import Mockable

@testable import moviesSwift

class VmDI: XCTestCase
{
    override func setUpWithError() throws
    {
        Resolver.RegisterVMServiceTypes()
    }

    override func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension Resolver
{
    static func RegisterVMServiceTypes()
    {
        //to not specify a return value for all mocked methods - set it to relaxed mode in global scope
        //or set it in the constructor of mock class like MockSample(policy: [.relaxedOptional, .relaxedVoid])
        //https://github.com/Kolos65/Mockable?tab=readme-ov-file#relaxed-mode
        MockerPolicy.default = .relaxed
        //register types
        register { CustomAppLogging() as ILoggingService }.scope(.application)
        register { CustomEventAgregator() as IMessagesCenter }.scope(.application)
        register { CustomSnackBarService() as ISnackbarService }.scope(.application)
        register { MockAlertDialogServiceGen(policy: [.relaxedOptional, .relaxedVoid]) as IAlertDialogService }.scope(.application)
        register { MockInfrastructureServicesGen(policy: [.relaxedOptional, .relaxedVoid]) as IInfrastructureServices }.scope(.application)
        register { MockMediaPickerServiceGen() as IMediaPickerService }.scope(.application)
        register { MockPageNavigationServiceGen() as IPageNavigationService }.scope(.application)
        //register viewmodels
        register { PageInjectedServices() }.scope(.application)
        register { MoviesPageViewModel(resolve()) }.scope(.unique)
        register { AddEditMoviePageViewModel(resolve()) }.scope(.unique)
       
//        single<PageInjectedServices> {  PageInjectedServices() }
//                           factory<MoviesPageViewModel> { MoviesPageViewModel(get()) }
//                           factory<AddEditMoviePageViewModel> { AddEditMoviePageViewModel(get()) }
        
//               val mockNavigationService = mockk<IPageNavigationService>(relaxed = true)
//               val mockInfraService = mockk<IInfrastructureServices> (relaxed = true);
//               //val mockSnackBar = mockk<ISnackbarService> (relaxed = true)
//               val mockMeidaPicker = mockk<IMediaPickerService> (relaxed = true)
//               val mockAlertDialog = mockk<IAlertDialogService> (relaxed = true)
    }
}

