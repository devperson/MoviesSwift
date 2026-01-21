@testable import moviesSwift

import Foundation


class CustomMovieRepository : IRepository
{
    typealias TEntity = Movie
    
    func FindById(_ id: Int) async throws -> Movie?
    {
        return Movie.Create("test", "test overview", "")
    }

    func GetListAsync(count: Int, skip: Int) async -> [Movie]
    {
        let list = [Movie.Create("test2", "test overview2", "")]
        return list;
    }

    func AddAsync(_ entity: Movie) async -> Int
    {
        return 1
    }

    func UpdateAsync(_ entity: Movie) async -> Int
    {
        return 1
    }

    func AddAllAsync(_ entities: [Movie]) async -> Int
    {
        return 1
    }

    func RemoveAsync(_ entity: Movie) async -> Int
    {
        return 1
    }

    func ClearAsync(reason: String) async -> Int
    {
        return 1
    }

}
