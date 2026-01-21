import Mockable
@testable import moviesSwift


@Mockable
protocol MovieServiceGen : IMovieService
{
    func GetListAsync(_ count: Int, _ skip: Int, _ remoteList: Bool) async -> Some<[MovieDto]>
    func GetById(_ id: Int) async -> Some<MovieDto>
    func AddAsync(name: String, overview: String, posterUrl: String?) async -> Some<MovieDto>
    func UpdateAsync(_ dtoModel: MovieDto) async -> Some<MovieDto>
    func RemoveAsync(_ dtoModel: MovieDto) async -> Some<Int>
}
