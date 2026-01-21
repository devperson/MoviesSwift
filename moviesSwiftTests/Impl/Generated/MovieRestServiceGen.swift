import Mockable
@testable import moviesSwift

//Mock IMovieRestService that will be generated like MockIGenMovieRestService
@Mockable
protocol MovieRestServiceGen : IMovieRestService
{
    func GetMovieRestlist() async throws -> [Movie]
}



