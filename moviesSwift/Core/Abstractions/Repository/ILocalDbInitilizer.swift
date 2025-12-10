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
    func InitDb() throws
    func Release(closeConnection: Bool)
}

extension ILocalDbInitilizer
{
    func Release()
    {
        self.Release(closeConnection: false)
    }
}
