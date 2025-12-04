import Foundation

class Movie: IEntity {
    var Id: Int = 0
    var Name: String = ""
    var Overview: String = ""
    var PosterUrl: String = ""

    static func Create(_ name: String?, _ overview: String?, _ posterUrl: String?) -> Movie {
        guard let name = name else { fatalError("name must not be null") }
        guard let overview = overview else { fatalError("overview must not be null") }

        let movie = Movie()
        movie.Name = name
        movie.Overview = overview
        if let poster = posterUrl { movie.PosterUrl = poster }
        return movie
    }
}
