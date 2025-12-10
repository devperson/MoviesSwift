import Foundation
import Resolver

class AppLoggingService: LoggableService, ILoggingService
{
    // Preserve original casing
    private var RowNumber: Int64 = 0
    private let ENTER_TAG = "➡Enter"
    private let EXIT_TAG = "🏃Exit"
    private let INDICATOR_TAG = "⏱Indicator_"
    private let HANDLED_ERROR = "💥Handled Exception: "
    private let UNHANDLED_ERROR = "💥Crash Unhandled: "

    private var AppLaunchCount: Int = 0
    var LastError: Error? = nil
    var HasError: Bool
    {
        LastError != nil
    }
    var OnErrorToken: UUID = UUID()

    @LazyInjected var errorTrackingService: IErrorTrackingService
    @LazyInjected var fileLogger: IFileLogger
    @LazyInjected var preferences: IPreferences
    @LazyInjected var platformConsole: IPlatformOutput

    override init()
    {
        super.init()
        OnErrorToken = errorTrackingService.OnError.AddListener(ErrorTrackingService_OnError)

        fileLogger.Init()
        AppLaunchCount = GetLaunchCount()
    }


    private func ErrorTrackingService_OnError(_ exString: String)
    {
        // convert string to NSError for tracking
        let err = NSError(domain: "AppLoggingService", code: -1, userInfo: [NSLocalizedDescriptionKey: exString])
        LogError(err, message: "Error happens in IErrorTrackingService", handled: true)
    }

    func TrackError(_ ex: Error, data: [String: String]?)
    {
        TrackInternal(ex: ex, handled: true, data: data)
    }

    func LogUnhandledError(_ ex: Error)
    {
        TrackInternal(ex: ex, handled: false, data: nil)
    }

    private func TrackInternal(ex: Error, handled: Bool, data: [String: String]? = nil)
    {
        SafeCall
        {
            LastError = ex
            LogError(ex, message: "", handled: handled)

            if handled //most error tracking service automatically uploads the unhandled errors
            {
                self.errorTrackingService.TrackError(ex, data: nil)
            }
        }
    }

    func Log(_ message: String)
    {
        SafeCall
        {
            RowNumber += 1
            let tag = GetLogAppTag(appLaunchCount: AppLaunchCount, rowNumber: RowNumber)
            let formatted = "\(tag) INFO:\(message)"
            fileLogger.Info(message: formatted)
            platformConsole.Info(formatted)
        }
    }

    func LogWarning(_ message: String)
    {
        SafeCall
        {
            RowNumber += 1
            let tag = GetLogAppTag(appLaunchCount: AppLaunchCount, rowNumber: RowNumber)
            let formatted = "\(tag) WARNING:\(message)"
            fileLogger.Warn(message: formatted)
            platformConsole.Warn(formatted)
        }
    }

    func LogError(_ ex: Error, message: String, handled: Bool)
    {
        SafeCall
        {
            RowNumber += 1
            let tag = GetLogAppTag(appLaunchCount: AppLaunchCount, rowNumber: RowNumber)

            var formatted = ""
            formatted += "\(tag) ERROR: "
            formatted += handled ? HANDLED_ERROR : UNHANDLED_ERROR
            if !message.isEmpty
            {
                formatted += ": \(message) - "
            }
            formatted += String(describing: ex)

            fileLogger.Warn(message: formatted)
            platformConsole.Error(formatted)
        }
    }

    func CreateSpecificLogger(key: String) throws -> ILogging
    {
        return try ConditionalLogger(key: key, logger: self, preferences: preferences)
    }

    func Header(_ headerMessage: String)
    {
        SafeCall
        {
            fileLogger.Info(message: headerMessage)
            platformConsole.Info(headerMessage)
        }
    }

    func LogMethodStarted(className: String, methodName: String, args: [Any?]?)
    {
        SafeCall
        {
            let debugMethodName = GetMethodNameWithParameters(className: className, funcName: methodName, args: args)
            Log("\(ENTER_TAG) \(debugMethodName)")
        }
    }

    func LogMethodStarted(_ methodName: String)
    {
        Log("\(ENTER_TAG) \(methodName)")
    }

    func LogMethodFinished(_ methodName: String)
    {
        Log("\(EXIT_TAG) \(methodName)")
    }

    func LogIndicator(name: String, message: String)
    {
        SafeCall
        {
            let msg = "********************************\(INDICATOR_TAG)\(name)*************************************"
            fileLogger.Info(message: msg)
            platformConsole.Info(msg)
        }
    }

    func GetSomeLogTextAsync() async throws -> String
    {
        let lines = try await fileLogger.GetLogListAsync()
        return lines.joined(separator: "\n")
    }

    func GetLogsFolder() -> String
    {
        return fileLogger.GetLogsFolder()
    }

    func GetCurrentLogFileName() -> String
    {
        return fileLogger.GetCurrentLogFileName()
    }

    func GetLastSessionLogBytes() async throws -> Data?
    {
        return try await fileLogger.GetCompressedLogsSync(getOnlyLastSession: true)
    }

    func GetCompressedLogFileBytes(getOnlyLastSession: Bool) async throws -> Data?
    {
        return try await fileLogger.GetCompressedLogsSync(getOnlyLastSession: getOnlyLastSession)
    }

    private func GetLaunchCount() -> Int
    {
        do
        {
            var launchCount = try preferences.Get("AppLaunchCount", defaultValue: -1)
            if launchCount != -1
            {
                launchCount += 1

            }
            else
            {
                launchCount = 0
            }

            try preferences.Set("AppLaunchCount", launchCount)
            return launchCount
        }
        catch
        {
            platformConsole.Error("Failed to get or set AppLaunchCount preference: \(error)")
            return 0
        }
    }

    private func GetLogAppTag(appLaunchCount: Int, rowNumber: Int64) -> String
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        let timeStr = formatter.string(from: Date())

        return "S(\(appLaunchCount))_R(\(rowNumber))_D(\(timeStr))"
    }


    private func SafeCall(_ action: () -> Void)
    {
        // Swift does not support catching non-throwing errors like Kotlin's `catch (Throwable)`.
        // Per your instruction, do not add try/catch if there are no Swift throws — just invoke the action.
        action()
    }

    /**
     Builds a readable debug string representing a method call, including the
     class name, function name, and a formatted preview of the arguments.
     Formatting rules:
     - **Scalar values** (`String`, `Int`, `Double`, `Float`, `Bool`, `Character`)
       are printed directly (e.g., `"hello"`, `42`, `true`).

     - **Arrays** (`[Any]`) are printed as:
           `[count] { item1, item2, ... }`
       Only the first 10 items are shown to keep logs concise.

     - **Collection types** (types whose `Mirror.displayStyle` is `.collection` or `.set`)
       follow the same `[count] { … }` convention using the first 10 children.

     - **Other object types** are printed as:
           `TypeName: description`
       where `TypeName` is the Swift type name and `description`
       is obtained from `String(describing:)`.

     The final output looks like:
           ClassName.methodName(arg1, arg2, arg3)

     This helper is intended for structured debug logging and avoids any
     platform-specific behavior outside of Swift’s reflection system.
     */
    private func GetMethodNameWithParameters(className: String, funcName: String?, args: [Any?]? = nil) -> String
    {

        let itemsCount = 10

        // Format each argument
        let argsString: String? = args?.map
        { arg -> String in
            guard let value = arg
            else
            {
                return "nil"
            }

            // MARK: - Simple scalar types
            switch value
            {
                case let v as String:    return "\"\(v)\""
                case let v as Int:       return "\(v)"
                case let v as Double:    return "\(v)"
                case let v as Float:     return "\(v)"
                case let v as Bool:      return v ? "true" : "false"
                case let v as Character: return "'\(v)'"
                default: break
            }

            // MARK: - Array types
            if let array = value as? [Any]
            {
                let preview = array.prefix(itemsCount).map
                {
                    String(describing: $0)
                }
                .joined(separator: ", ")

                return "[\(array.count)] { \(preview) }"
            }

            // MARK: - Collection types using Mirror
            let mirror = Mirror(reflecting: value)

            if let style = mirror.displayStyle, style == .collection || style == .set
            {
                let children = Array(mirror.children)
                let preview = children.prefix(itemsCount).map
                {
                    String(describing: $0.value)
                }
                .joined(separator: ", ")

                return "\(type(of: value))[\(children.count)] { \(preview) }"
            }

            // MARK: - Default object description
            // Swift does not produce JVM-like ClassName@hashCode strings,
            // so we can safely show "TypeName: description"
            let typeName = String(describing: type(of: value))
            let description = String(describing: value)

            return "\(typeName): \(description)"

        }
        .joined(separator: ", ")

        return "\(className).\(funcName ?? "?")(\(argsString ?? ""))"
    }

}

class ConditionalLogger: ILogging
{
    private let key: String
    private let logger: ILogging
    private let preferences: IPreferences
    private let canLog: Bool

    init(key: String, logger: ILogging, preferences: IPreferences) throws
    {
        self.key = key
        self.logger = logger
        self.preferences = preferences
        self.canLog = try preferences.Get(key, defaultValue: false)
    }

    func Log(_ message: String)
    {
        if canLog
        {
            logger.Log(message)
        }
    }

    func LogWarning(_ message: String)
    {
        if canLog
        {
            logger.LogWarning(message)
        }
    }

    func LogMethodStarted(className: String, methodName: String, args: [Any?]?)
    {
        if canLog
        {
            logger.LogMethodStarted(className: className, methodName: methodName, args: args)
        }
    }
}
