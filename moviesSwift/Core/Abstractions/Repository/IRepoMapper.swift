import Foundation

protocol IRepoMapper<TEntity, Tb>
{
    associatedtype TEntity: IEntity
    associatedtype Tb: ITable

    func ToTb(entity: TEntity) -> Tb
    func ToEntity(tb: Tb) -> TEntity
    func MoveData(from: TEntity, to: Tb)
}
