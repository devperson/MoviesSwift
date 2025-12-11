import XCTest
import Resolver

@testable import moviesSwift

final class MovieServiceTest: DomainDI
{
    func testT1_1AddMovieTest() async
    {
        let movieService: IMovieService = ContainerLocator.Resolve()
        let result = await movieService.AddAsync(name: "first product", overview: "test overview", posterUrl: "");
        
        XCTAssertTrue(result.Success, "IMoviesService.AddAsync() failed in T1_1AddMovieTest()");
    }
    
    
    func testT1_2GetMovieListTest() async throws
    {
        let movieService: IMovieService = ContainerLocator.Resolve()
        let result = await movieService.GetListAsync();
        
        XCTAssertTrue(result.Success, "IMoviesService.GetListAsync() failed in T1_2GetMovieListTest()");
        XCTAssertTrue(result.ValueOrThrow.count > 0, "Movie count is zero in T1_2GetMovieListTest()");
    }
    
    
    func testT1_3GetMovieTest() async
    {
        let movieService: IMovieService = ContainerLocator.Resolve()
        let result = await movieService.GetById(1);
        XCTAssertTrue(result.Success, "IMoviesService.GetById() failed in T1_3GetMovieTest()");
    }
    
    
    func testT1_4UpdateMovieTest() async
    {
        let movieService: IMovieService = ContainerLocator.Resolve()
        let result = await movieService.GetById(1);
        XCTAssertTrue(result.Success, "IMoviesService.GetById() failed in T1_3GetMovieTest()");
        
        var item = result.ValueOrThrow;
        item.Name = "updated name";
        item.Overview = "updated overview";
        item.PosterUrl = "updated poster";
        let updateResult = await movieService.UpdateAsync(item);
        XCTAssertTrue(updateResult.Success, "IMoviesService.UpdateAsync() failed in T1_3UpdateMovieTest()");
    }
    
    
    func testT1_5RemoveMovieTest() async
    {
        let movieService: IMovieService = ContainerLocator.Resolve()
        let result = await movieService.GetById(1);
        XCTAssertTrue(result.Success, "IMoviesService.GetById() failed in T1_3UpdateMovieTest()");
        
        let item = result.ValueOrThrow;
        let removeResult = await movieService.RemoveAsync(item);
        XCTAssertTrue(removeResult.Success, "IMoviesService.RemoveAsync() failed in T1_3RemoveMovieTest()");
    }
}
