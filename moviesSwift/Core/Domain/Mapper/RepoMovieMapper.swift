struct RepoMovieMapper: IRepoMapper
{
    func ToTb(entity: Movie) -> MovieTb
    {
        let tb = MovieTb()
        tb.Id = entity.Id
        tb.Name = entity.Name
        tb.Overview = entity.Overview

        // Kotlin: if(entity.PosterUrl.isNullOrEmpty()) "" else entity.PosterUrl!!
        tb.PostUrl = entity.PosterUrl.isEmpty ? "" : entity.PosterUrl

        return tb
    }

    func ToEntity(tb: MovieTb) -> Movie
    {
        let movie = Movie.Create(tb.Name, tb.Overview, tb.PostUrl)

        movie.Id = tb.Id
        return movie
    }

    func MoveData(from: Movie, to: MovieTb)
    {
        to.Name = from.Name
        to.Overview = from.Overview
        to.PostUrl = from.PosterUrl
    }
}
