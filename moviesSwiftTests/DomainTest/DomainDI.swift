import XCTest
import Resolver
import Mockable

@testable import moviesSwift

class DomainDI: XCTestCase
{
    override func setUpWithError() throws
    {
        Resolver.RegisterDomainTypes()
    }

    override func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension Resolver
{
    static func RegisterDomainTypes()
    {
        register { CustomAppLogging() as ILoggingService }.scope(.application)
        register { CustomMovieRepository() as any IRepository<Movie> }.scope(.application)
        register { MoviesService() as IMovieService }.scope(.application)
        
        //register mock IMovieRestService
        let movie = Movie.Create("test rest1", "overview rest1", "");
        movie.Id = 1;
        let mockrestService = MockMovieRestServiceGen()
        //mock the GetMovieRestlist()
        given(mockrestService).GetMovieRestlist().willReturn([movie])
        //register
        register { mockrestService as IMovieRestService }.scope(.application)
    }
    
    
}


