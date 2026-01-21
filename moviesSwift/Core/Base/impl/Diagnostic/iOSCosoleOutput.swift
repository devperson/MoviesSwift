import OSLog

class iOSConsoleOutput: IPlatformOutput
{
    let logger: Logger;
    init()
    {
        logger = Logger(subsystem: "", category: "AppLogger")
    }
    
    func Error(_ message: String)
    {
        logger.fault("\(message)")
    }
    
    func Info(_ message: String)
    {
        logger.info("\(message)")
    }
    
    func Warn(_ message: String)
    {
        logger.warning("\(message)")
    }
    
    
}

