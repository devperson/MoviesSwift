import Foundation

protocol ILocalDbInitilizer
{
    var DbsFolderName: String { get }
    var DbExtenstion: String { get }
    var DbName: String { get }
    func GetDbPath() -> String
    func GetDbDir() -> String

    func GetDbConnection() -> Any
    func Init() async
    func Release(closeConnection: Bool)
}
