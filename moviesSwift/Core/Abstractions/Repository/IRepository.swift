import Foundation

protocol IRepository<TEntity>
{
    associatedtype TEntity: IEntity

    func FindById(_ id: Int) async throws -> TEntity?
    func GetListAsync(count: Int, skip: Int) async throws -> [TEntity]
    @discardableResult
    func AddAsync(_ entity: TEntity) async throws -> Int
    @discardableResult
    func UpdateAsync(_ entity: TEntity) async throws -> Int
    @discardableResult
    func AddAllAsync(_ entities: [TEntity]) async throws -> Int
    func RemoveAsync(_ entity: TEntity) async throws -> Int
    func ClearAsync(reason: String) async throws -> Int
}

extension IRepository
{
    func GetListAsync(count: Int = -1, skip: Int = 0) async throws -> [TEntity]
    {
        let result = try await GetListAsync(count: count, skip: skip)
        return result
    }
}
