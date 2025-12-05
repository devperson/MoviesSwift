import Foundation

protocol IMovieService {
    func GetListAsync(count: Int, skip: Int, remoteList: Bool) async -> Some<[MovieDto]>
    func GetById(_ id: Int) async -> Some<MovieDto>
    func AddAsync(name: String, overview: String, posterUrl: String?) async -> Some<MovieDto>
    func UpdateAsync(_ dtoModel: MovieDto) async -> Some<MovieDto>
    func RemoveAsync(_ dtoModel: MovieDto) async -> Some<Int>
}

extension IMovieService
{
    func GetListAsync(count: Int = 10, skip: Int = 0, remoteList: Bool = true) async -> Some<[MovieDto]>
    {
        return await self.GetListAsync(count: count, skip: skip, remoteList: remoteList)
    }
}
