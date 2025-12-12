@testable import moviesSwift

import Foundation

class CustomAppLogging: ILoggingService
{
    // MARK: - Static Tags
    static let EnterTag: String = "➡Enter"
    static let ExitTag: String = "🏃Exit"
    static let IndicatorTag: String = "⏱Indicator_"

    // MARK: - Properties
    var LastError: Error? = nil

    var HasError: Bool {
        return LastError != nil
    }

    // MARK: - Private Helpers
    private func getFormattedDate() -> String
    {
        // Swift version of "HH:mm:ss:microseconds"

        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss:SSSSSS" // microseconds-like precision
        formatter.locale = Locale(identifier: "en_US_POSIX")

        return formatter.string(from: now)
    }

    // MARK: - Logging
    func Log(_ message: String)
    {
        print("\(getFormattedDate())_\(message)")
    }

    func LogWarning(_ message: String)
    {
        print("\(getFormattedDate())WARNING: \(message)")
    }

    func LogError(_ ex: Error, message: String, handled: Bool)
    {
        print("ERROR: \(message), 💥Handled Exception: \(ex)")
    }

    func TrackError(_ ex: Error, data: [String : String]?)
    {
        LastError = ex
        print("💥Handled Exception: \(ex)")
    }

    func LogUnhandledError(_ ex: Error)
    {
        LastError = ex
    }

    func Header(_ headerMessage: String)
    {
        fatalError("Not yet implemented")
    }

    func LogMethodStarted(className: String, methodName: String, args: [Any?]?)
    {
        print("\(Self.EnterTag) \(className).\(methodName)()")
    }

    func LogMethodStarted(_ methodName: String)
    {
        print("\(Self.EnterTag) \(methodName)")
    }

    func LogMethodFinished(_ methodName: String)
    {
        print("\(Self.ExitTag) \(methodName)")
    }

    func LogIndicator(name: String, message: String)
    {
        fatalError("Not yet implemented")
    }

    // MARK: - Async / File Methods
    func GetCompressedLogFileBytes(getOnlyLastSession: Bool) async -> Data?
    {
        fatalError("Not yet implemented")
    }

    func GetSomeLogTextAsync() async -> String
    {
        fatalError("Not yet implemented")
    }

    func GetLogsFolder() -> String
    {
        fatalError("Not yet implemented")
    }

    func GetCurrentLogFileName() -> String
    {
        fatalError("Not yet implemented")
    }

    func GetLastSessionLogBytes() async -> Data?
    {
        fatalError("Not yet implemented")
    }

    func CreateSpecificLogger(key: String) -> ILogging
    {
        fatalError("Not yet implemented")
    }
}


