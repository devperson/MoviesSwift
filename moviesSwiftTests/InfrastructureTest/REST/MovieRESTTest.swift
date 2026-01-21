import XCTest
//import Resolver

@testable import moviesSwift

final class MovieRESTTest: REST_DI
{
    
    func testT1_1TestGetMovies() async throws
    {
        let movieRestService: IMovieRestService =  ContainerLocator.Resolve()
        let list = try await movieRestService.GetMovieRestlist()
        XCTAssertFalse(list.isEmpty)
        XCTAssertTrue(list.first!.PosterUrl.contains("http"))
    }
}
