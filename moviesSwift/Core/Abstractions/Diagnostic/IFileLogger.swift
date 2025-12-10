import Foundation

protocol IFileLogger
{
    func Init()
    func Info(message: String)
    func Warn(message: String)
    func Error(message: String)
    func GetCompressedLogsSync(getOnlyLastSession: Bool) async throws -> Data?
    func GetLogListAsync() async throws -> [String]
    func GetLogsFolder() -> String
    func GetCurrentLogFileName() -> String
}
