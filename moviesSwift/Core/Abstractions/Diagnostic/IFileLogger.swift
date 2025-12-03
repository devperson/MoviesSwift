import Foundation

protocol IFileLogger {
    func Init()
    func Info(_ message: String)
    func Warn(_ message: String)
    func Error(_ message: String)
    func GetCompressedLogsSync(getOnlyLastSession: Bool) async -> Data?
    func GetLogListAsync() async -> [String]
    func GetLogsFolder() -> String
    func GetCurrentLogFileName() -> String
}
