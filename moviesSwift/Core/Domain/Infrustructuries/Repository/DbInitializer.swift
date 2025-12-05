import Foundation
import RealmSwift
import Resolver

class DbInitializer: LoggableService, ILocalDbInitilizer
{
    private var realmConn: Realm?
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

    func InitDb() async throws
    {
        LogMethodStart(#function)
        
        guard !isInited else {
            print("DbInitializer Init() skipped — already initialized")
            return
        }
        isInited = true
        
        let config = Realm.Configuration(
            fileURL: URL(filePath: try GetDbPath()),
            schemaVersion: 1,
            objectTypes: [
                MovieTb.self    // add all Realm Object types here
            ]
        )

        realmConn = try Realm(configuration: config, queue: nil)
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

    // MARK: - Get Connection

    func GetDbConnection() throws -> Any
    {
        LogMethodStart(#function)
        
        guard let realmConn else
        {
            throw DbError.failed("DbInitializer: Database connection is not initialized.")
        }
        return realmConn
    }

  
    func Release(closeConnection: Bool) async
    {
        LogMethodStart(#function)
        
        isInited = false

        if closeConnection
        {
            realmConn = nil    // RealmSwift cannot be explicitly closed
        }
    }
}

enum DbError: Error
{
    case notInitialized
    case failed(String)
}
