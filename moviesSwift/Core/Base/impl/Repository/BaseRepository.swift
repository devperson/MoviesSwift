import Foundation
import RealmSwift
import Resolver

class BaseRepository<TEntity: IEntity, Tb>: LoggableService, IRepository where Tb: RealmSwift.Object & ITable
{
    @LazyInjected private var mapper: any IRepoMapper<TEntity, Tb>
    @LazyInjected private var dbInitializer: ILocalDbInitilizer

    private var realm: Realm?
    private let tableType: Tb.Type

    init(tableType: Tb.Type)
    {
        self.tableType = tableType
    }

    private func EnsureInitialized() throws
    {
        if realm == nil
        {
            realm = try dbInitializer.GetDbConnection() as? Realm
        }
    }

    private func GetNextId() throws -> Int
    {
        LogMethodStart(#function)
        try EnsureInitialized()
        guard let realm
        else
        {
            return 1
        }

        let maxId = realm.objects(Tb.self).max(ofProperty: "Id") as Int? ?? 0
        return maxId == 0 ? 1 : maxId + 1
    }

    // MARK: - CRUD (async equivalents)

    func GetListAsync(count: Int, skip: Int) async throws -> [TEntity]
    {
        LogMethodStart(#function, count, skip)
        try EnsureInitialized()
        guard let realm
        else
        {
            return []
        }

        if count > 0
        {
            let queried = realm.objects(Tb.self).where
            {
                $0.Id > skip
            }
            .sorted(byKeyPath: "Id", ascending: true)

            let limitedResults = Array(queried.prefix(count))   // converts Slice<Results<Tb>> → [Tb]
            return limitedResults.map
            {
                mapper.ToEntity(tb: $0)
            }
        }
        else
        {
            let results = realm.objects(Tb.self)
            return results.map
            {
                mapper.ToEntity(tb: $0)
            }
        }
    }

    func AddAsync(_ entity: TEntity) async throws -> Int
    {
        LogMethodStart(#function, entity)
        try EnsureInitialized()
        guard let realm
        else
        {
            return 0
        }

        var entity = entity
        entity.Id = try GetNextId()

        let tb = mapper.ToTb(entity: entity)

        try realm.write
        {
            realm.add(tb, update: .modified)
        }

        return 1
    }

    func AddAllAsync(_ entities: [TEntity]) async throws -> Int
    {
        LogMethodStart(#function, entities)
        try EnsureInitialized()
        guard let realm
        else
        {
            return 0
        }

        var lastId = -1

        try realm.write
        {
            for entity in entities
            {
                if lastId != -1
                {
                    lastId += 1
                }
                else
                {
                    lastId = try self.GetNextId()
                }

                var e = entity
                e.Id = lastId

                let tb = mapper.ToTb(entity: e)
                realm.add(tb, update: .modified)
            }
        }

        return entities.count
    }

    func FindById(_ id: Int) async throws -> TEntity?
    {
        LogMethodStart(#function, id)
        try EnsureInitialized()
        guard let realm
        else
        {
            return nil
        }

        return realm.object(ofType: Tb.self, forPrimaryKey: id).map
            {
                mapper.ToEntity(tb: $0)
            }
    }

    func UpdateAsync(_ entity: TEntity) async throws -> Int
    {
        LogMethodStart(#function, entity)
        try EnsureInitialized()
        guard let realm
        else
        {
            return 0
        }

        var updated = false

        try realm.write
        {
            if let tb = realm.object(ofType: Tb.self, forPrimaryKey: entity.Id)
            {
                mapper.MoveData(from: entity, to: tb)
                updated = true
            }
        }

        return updated ? 1 : 0
    }

    func RemoveAsync(_ entity: TEntity) async throws -> Int
    {
        LogMethodStart(#function, entity)
        try EnsureInitialized()
        guard let realm
        else
        {
            return 0
        }

        var removed = false

        try realm.write
        {
            if let tb = realm.object(ofType: Tb.self, forPrimaryKey: entity.Id)
            {
                realm.delete(tb)
                removed = true
            }
        }

        return removed ? 1 : 0
    }

    func ClearAsync(reason: String) async throws -> Int
    {
        LogMethodStart(#function, reason)
        try EnsureInitialized()
        guard let realm
        else
        {
            return 0
        }

        var deleted = 0

        try realm.write
        {
            let all = realm.objects(Tb.self)
            deleted = all.count
            realm.delete(all)
        }

        return deleted
    }
}
