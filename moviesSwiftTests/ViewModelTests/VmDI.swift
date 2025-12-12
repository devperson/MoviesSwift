import XCTest
import Resolver
import Mockable

@testable import moviesSwift


class VmDI: XCTestCase
{
    override func setUpWithError() throws
    {
        //register types
        Resolver.RegisterVMServiceTypes()
        
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
        
        let mockMovieService = MockMovieServiceGen()
        //mock AddAsync() method
        let newMovie = MovieDto(Id: 1, Name: "Test movie from unit test", Overview: "unit test overview1", PosterUrl: "")
        let someNewMovie = Some<MovieDto>.FromValue(newMovie)
        given(mockMovieService).AddAsync(name: Parameter.value("Test movie1"), overview: Parameter.value("test overview1"), posterUrl:Parameter.value("")).willReturn(someNewMovie)
        //mock AddAsync() method
        given(mockMovieService).UpdateAsync(Parameter.value(newMovie)).willReturn(someNewMovie)
        register { mockMovieService as IMovieService }.scope(.application)
        
        //register viewmodels
        register { PageInjectedServices() }.scope(.application)
        register { MoviesPageViewModel(resolve()) }.scope(.unique)
        register { AddEditMoviePageViewModel(resolve()) }.scope(.unique)
    }
}

