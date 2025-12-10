import Foundation
import Resolver



class MoviesService : LoggableService, IMovieService
{
    @LazyInjected
    var movieRepository: any IRepository<Movie>
    @LazyInjected
    var movieRestService: IMovieRestService

    func GetListAsync(count: Int, skip: Int, remoteList: Bool) async -> Some<[MovieDto]>
    {
        do
        {
            LogMethodStart(#function, count, skip, remoteList);

            var canLoadLocal: Bool = true;
            var localList: [Movie]? = nil;
            if (remoteList)
            {
                canLoadLocal = false;
            }
            else
            {
                localList = try await self.movieRepository.GetListAsync();
                canLoadLocal = localList!.count > 0;
            }

            if (canLoadLocal)
            {
                loggingService.Log("MoviesService.GetListAsync(): loading from Local storage because canLoadLocal: $canLoadLocal")
                let dtoList = try localList!.map
                {s in
                    
                    let dto = try s.ToDto()
                    if let movieDto = dto as? MovieDto
                    {
                        return movieDto;
                    }
                    else
                    {
                        throw AppServiceException("Failed to cast s (Movie) to dto (MovieDto), s: \(s.self)")
                    }
                }
                return Some.FromValue(dtoList);
            }
            else
            {
                loggingService.Log("MoviesService.GetListAsync(): loading from Remote server because canLoadLocal: $canLoadLocal")
                //download all list
                let remoteList = try await movieRestService.GetMovieRestlist();
                _ = try await movieRepository.ClearAsync(reason: "MovieService: Delete all items requested when syncing");
                _ = try await movieRepository.AddAllAsync(remoteList);
                loggingService.Log("MoviesService.GetListAsync(): Sync completed deletedCount: $deletedCount, insertedCount: $insertedCount")

                //return dto list
                let dtoList = try remoteList.map{s in try s.ToDto() as! MovieDto};
                return Some.FromValue(dtoList);
            }
        }
        catch
        {
            return Some.FromError(error);
        }
    }

    func GetById(_ id: Int) async -> Some<MovieDto>
    {
        do
        {
            LogMethodStart(#function, id);

            let movie = try await movieRepository.FindById(id)
            let dtoMovie = try movie?.ToDto() as? MovieDto;
            return Some.FromValue(dtoMovie);
        }
        catch
        {
            return Some.FromError(error);
        }
    }

    func AddAsync(name: String, overview: String, posterUrl: String?) async -> Some<MovieDto>
    {
        do
        {
            LogMethodStart(#function, name,overview,posterUrl);

            let movie = Movie.Create(name, overview, posterUrl);
            try await self.movieRepository.AddAsync(movie);

            let dtoMovie = try movie.ToDto() as! MovieDto;
            return Some.FromValue(dtoMovie);
        }
        catch
        {
            return Some.FromError(error);
        }
    }

    func UpdateAsync(_ dtoModel: MovieDto) async -> Some<MovieDto>
    {
        do
        {
            LogMethodStart(#function, dtoModel);

            let movie = try dtoModel.ToEntity() as! Movie
            try await self.movieRepository.UpdateAsync(movie);

            return Some.FromValue(dtoModel);
        }
        catch
        {
            return Some.FromError(error);
        }
    }

    func RemoveAsync(_ dtoModel: MovieDto) async -> Some<Int>
    {
        do
        {
            LogMethodStart(#function, dtoModel);

            let movie = try dtoModel.ToEntity() as! Movie;
            let res = try await self.movieRepository.RemoveAsync(movie);

            return Some.FromValue(res);
        }
        catch
        {
            return Some.FromError(error);
        }
    }
}

