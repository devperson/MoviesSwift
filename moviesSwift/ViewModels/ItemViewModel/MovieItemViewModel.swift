import Foundation

class MovieItemViewModel: LoggableViewModel, Equatable
{
    var Id: Int = 0
    var Name: String = ""
    var Overview: String = ""
    var PosterUrl: String? = ""
    private var movieDto: MovieDto?

    override init()
    {
        super.init()
    }

    init(_ dto: MovieDto)
    {
        super.init()
        Id = dto.Id
        Name = dto.Name
        Overview = dto.Overview
        PosterUrl = dto.PosterUrl
        movieDto = dto
    }

    func ToDto() -> MovieDto
    {
        movieDto?.Id = Id
        movieDto?.Name = Name
        movieDto?.Overview = Overview
        movieDto?.PosterUrl = PosterUrl
        return movieDto!
    }
    
    static func == (lhs: MovieItemViewModel, rhs: MovieItemViewModel) -> Bool
    {
        return lhs.movieDto?.Id == rhs.movieDto?.Id
    }
}
