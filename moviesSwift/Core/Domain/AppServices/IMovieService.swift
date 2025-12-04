import Foundation

protocol IMovieService {
    func GetListAsync(count: Int, skip: Int, remoteList: Bool) async -> Some<[MovieDto]>
    func GetById(_ id: Int) async throws -> Some<MovieDto>
    func AddAsync(name: String, overview: String, posterUrl: String?) async -> Some<MovieDto>
    func UpdateAsync(_ dtoModel: MovieDto) async -> Some<MovieDto>
    func RemoveAsync(_ dtoModel: MovieDto) async -> Some<Int>
}
