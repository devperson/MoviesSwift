import Foundation

protocol IRepository {
    associatedtype TEntity: IEntity

    func FindById(_ id: Int) async -> TEntity?
    func GetListAsync(count: Int, skip: Int) async -> [TEntity]
    func AddAsync(_ entity: TEntity) async -> Int
    func UpdateAsync(_ entity: TEntity) async -> Int
    func AddAllAsync(_ entities: [TEntity]) async -> Int
    func RemoveAsync(_ entity: TEntity) async -> Int
    func ClearAsync(reason: String) async -> Int
}
