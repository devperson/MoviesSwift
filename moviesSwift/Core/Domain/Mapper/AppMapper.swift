import Foundation

extension IEntity
{
    func ToDto() throws -> IAppDto
    {
        if let movie = self as? Movie
        {
            return MovieDto(Id: movie.Id,
                            Name: movie.Name,
                            Overview: movie.Overview,
                            PosterUrl: movie.PosterUrl)
        }

        throw MappingError.CannotConvertEntity(entity: "Failed to find corresponding dto model for \(type(of: self)) entity")
    }
}

extension IAppDto
{
    func ToEntity() throws -> IEntity
    {
        if let dto = self as? MovieDto
        {
            let movie = Movie.Create(dto.Name,
                                     dto.Overview,
                                     dto.PosterUrl)
            movie.Id = dto.Id
            return movie
        }

        throw MappingError.CannotConvertDto(dto: "Failed to find corresponding entity model for \(type(of: self)) dto")
    }
}
