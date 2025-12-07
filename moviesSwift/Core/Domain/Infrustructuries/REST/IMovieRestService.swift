import Foundation

protocol IMovieRestService
{
    func GetMovieRestlist() async throws -> [Movie]
}
