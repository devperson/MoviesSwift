class MovieRepository : BaseRepository<Movie, MovieTb>
{
    init()
    {
        super.init(tableType: MovieTb.self)
    }
}
