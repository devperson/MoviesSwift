
import Foundation

class MovieRestService : RestService, IMovieRestService
{
    let baseImageHost = "https://image.tmdb.org/t/p/w300/";
    func GetMovieRestlist() async throws -> [Movie]
    {
        LogMethodStart(#function)

        let result = try await Get(MovieListResponse.self, RestRequest(
            apiEndpoint: "movie/popular?api_key=424f4be6472e955cadf36e104d8762d7",
            withBearer: false))

        let list = result.Movies.map
        { s -> Movie in
        
            let posterUrl: String

            if s.PosterPath.hasPrefix("/") {
                let path = String(s.PosterPath.dropFirst())
                posterUrl = baseImageHost + path
            } else {
                posterUrl = ""
            }

            let movie = Movie()
            movie.Id = s.Id
            movie.Name = s.Name
            movie.Overview = s.Overview
            movie.PosterUrl = posterUrl

            return movie
        }

        return list;
    }
}



struct MovieListResponse: Codable {
    let Page: Int
    let TotalPages: Int
    let TotalResults: Int
    let Movies: [MovieRestModel]

    enum CodingKeys: String, CodingKey {
        case Page = "page"
        case TotalPages = "total_pages"
        case TotalResults = "total_results"
        case Movies = "results"
    }
}

struct MovieRestModel: Codable {
    let Id: Int
    let Name: String
    let PosterPath: String
    let Overview: String

    enum CodingKeys: String, CodingKey {
        case Id = "id"
        case Name = "title"
        case PosterPath = "poster_path"
        case Overview = "overview"
    }
}

