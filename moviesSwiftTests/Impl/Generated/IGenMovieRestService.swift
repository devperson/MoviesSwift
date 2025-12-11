import Mockable
@testable import moviesSwift

//Mock IMovieRestService that will be generated like MockIGenMovieRestService
@Mockable
protocol MovieRestService : IMovieRestService
{
    func GetMovieRestlist() async throws -> [Movie]
}



