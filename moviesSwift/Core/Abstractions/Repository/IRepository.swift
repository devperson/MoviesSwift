import Foundation

protocol IRepository {
    associatedtype TEntity: IEntity

    func FindById(_ id: Int) async throws-> TEntity?
    func GetListAsync(count: Int, skip: Int) async throws-> [TEntity]
    func AddAsync(_ entity: TEntity) async throws-> Int
    func UpdateAsync(_ entity: TEntity) async throws-> Int
    func AddAllAsync(_ entities: [TEntity]) async throws-> Int
    func RemoveAsync(_ entity: TEntity) async throws-> Int
    func ClearAsync(reason: String) async throws-> Int
}
