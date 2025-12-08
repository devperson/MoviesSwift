import XCTest
import Resolver

@testable import moviesSwift

class RepoDi: XCTestCase
{
    override func setUpWithError() throws
    {
        Resolver.RegisterTypes()
    }

    override func tearDownWithError() throws
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension Resolver
{
    static func RegisterTypes()
    {
        register { MockLogger() as ILoggingService }.scope(.application)
        register { DbInitializer() as ILocalDbInitilizer }.scope(.application)
        register { RepoMovieMapper() as any IRepoMapper<Movie, MovieTb> }.scope(.application)
        register { MovieRepository() as any IRepository<Movie> }.scope(.application)
    }
}

