import Foundation
import RealmSwift
import Resolver

class DbInitializer: LoggableService, ILocalDbInitilizer
{
   
    //private var realmConn: Realm?
    private var config: Realm.Configuration?
    private var isInited: Bool = false
    @LazyInjected private var directoryService: IDirectoryService

    let DbsFolderName = "Databases"
    let DbExtenstion = ".realm"
    var DbName: String = ""
    
    override init()
    {
        super.init()
        DbName = "AppDb\(DbExtenstion)"
    }

    func InitDb() throws
    {
        guard !isInited else { return }
        isInited = true
        
        let path = try GetDbPath()
        
        // Do NOT create Realm here!
        // Just save config.
        config = Realm.Configuration(
            fileURL: URL(fileURLWithPath: path),
            schemaVersion: 1,
            objectTypes: [MovieTb.self])
    }

    func GetDbConnection() throws -> Any
    {
        guard let config else
        {
            throw DbError("Database is not initialized.")
        }        
        // ALWAYS create a fresh instance
        //https://stackoverflow.com/questions/41781775/realm-accessed-from-incorrect-thread-again
        return try Realm(configuration: config)
    }

   
    func GetDbDir() throws -> String
    {
        LogMethodStart(#function)
        let url = try getDbDirInternal()
        return url.path()
    }

    func getDbDirInternal() throws -> URL
    {
        let baseDir = directoryService.GetAppDataDir()   // string path from your service
        let dirURL = URL(fileURLWithPath: baseDir).appendingPathComponent(DbsFolderName)

        if !FileManager.default.fileExists(atPath: dirURL.path)
        {
            try FileManager.default.createDirectory(at: dirURL, withIntermediateDirectories: true)
        }

        return dirURL
    }

    func GetDbPath() throws -> String
    {
        LogMethodStart(#function)
        let url = try getDbDirInternal().appendingPathComponent(DbName)
        return url.path()
    }

    func Release(closeConnection: Bool)
    {
        isInited = false
        config = nil
    }
}

class DbError: AppException
{
    
}

//enum DbError: Error
//{
//    case notInitialized
//    case failed(String)
//}
