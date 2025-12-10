import Resolver

open class LoggableService
{
    @LazyInjected var loggingService: ILoggingService
    private(set) var specificLogger: ILogging?
    private var specificLoggerInitialized = false

    // MARK: - Method Logging
    func LogMethodStart(_ methodName: String, _ args: Any?...)
    {
        let className = String(describing: type(of: self))
        loggingService.LogMethodStarted(className: className, methodName: methodName, args: args)
    }

    // MARK: - Specific Logger Initialization
    func initSpecificLogger(_ key: String) throws
    {
        if !specificLoggerInitialized
        {
            specificLogger = try loggingService.CreateSpecificLogger(key: key)
            specificLoggerInitialized = true
        }
    }

    // MARK: - Specific Logging
    func SpecificLogMethodStart(_ methodName: String, _ args: Any?...)
    {
        guard let specificLogger
        else
        {
            return
        }
        let className = String(describing: type(of: self))
        specificLogger.LogMethodStarted(className: className, methodName: methodName, args: args)
    }
}
