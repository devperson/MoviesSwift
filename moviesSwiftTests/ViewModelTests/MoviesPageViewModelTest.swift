import XCTest
//import Resolver

@testable import moviesSwift

final class VMMoviesPageViewModelTest: VmDI
{
    
    //private val mainVm by inject<MoviesPageViewModel>()
    var loggingService: ILoggingService { get { ContainerLocator.Resolve() } }
    
    
    func testT1_1TestLoadMethod() async
    {
        let mainVm: MoviesPageViewModel = ContainerLocator.Resolve();
        await mainVm.LoadData();
        XCTAssertTrue(mainVm.MovieItems.count > 0)
        XCTAssertFalse(loggingService.HasError)
    }
    
    func testT1_2TestNavigateToCreateProduct()  async
    {
        let mainVm: MoviesPageViewModel = ContainerLocator.Resolve();
        await mainVm.AddCommand.ExecuteAsync()
        XCTAssertFalse(loggingService.HasError)
    }
    
    
    func testT1_3TestPullRefresh()  async
    {
        let mainVm: MoviesPageViewModel = ContainerLocator.Resolve();
        await mainVm.RefreshCommand.ExecuteAsync()
        XCTAssertFalse(loggingService.HasError)
    }
}
