import Foundation

protocol ILocalDbInitilizer
{
    var DbsFolderName: String
    {
        get
    }
    var DbExtenstion: String
    {
        get
    }
    var DbName: String
    {
        get
    }
    func GetDbPath() throws -> String
    func GetDbDir() throws -> String

    func GetDbConnection() throws -> Any
    func InitDb() async throws
    func Release(closeConnection: Bool) async
}

extension ILocalDbInitilizer
{
    func Release(closeConnection: Bool = false) async
    {
        await Release(closeConnection: closeConnection)
    }
}
