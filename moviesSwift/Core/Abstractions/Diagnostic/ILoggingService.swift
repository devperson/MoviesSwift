import Foundation

protocol ILogging
{
    func Log(_ message: String)
    func LogWarning(_ message: String)
    func LogMethodStarted(className: String, methodName: String, args: [Any?]?)
}

protocol ILoggingService: ILogging
{
    var LastError: Error?
    {
        get set
    }
    var HasError: Bool
    {
        get
    }

    func LogMethodStarted(_ methodName: String)
    func Header(_ headerMessage: String)
    func LogMethodFinished(_ methodName: String)
    func LogIndicator(name: String, message: String)
    func LogError(_ ex: Error, message: String, handled: Bool)
    func TrackError(_ ex: Error, data: [String: String]?)
    func LogUnhandledError(_ ex: Error)
    func GetCompressedLogFileBytes(getOnlyLastSession: Bool) async throws -> Data?
    func GetSomeLogTextAsync() async throws-> String
    func GetLogsFolder() -> String
    func GetCurrentLogFileName() -> String
    func GetLastSessionLogBytes() async throws -> Data?
    func CreateSpecificLogger(key: String) throws -> ILogging
}

extension ILoggingService
{
    func LogError(_ ex: Error)
    {
        LogError(ex, message: "", handled: true)
    }

    func LogError(_ ex: Error, _ message: String)
    {
        LogError(ex, message: "", handled: true)
    }

    func TrackError(_ ex: Error, data: [String: String]? = nil)
    {
        TrackError(ex, data: data)
    }
}

struct SpecificLoggingKeys
{
    static let LogEssentialServices = "LogEssentialServices"
    static let LogUIServices = "LogUIServices"
    static let LogUIControlsKey = "LogUIControlsKey"
    static let LogUIPageKey = "LogUIPageKey"
    static let LogUINavigationKey = "LogUINavigationKey"
    static let LogUITableCells = "LogUITableCells"
}
