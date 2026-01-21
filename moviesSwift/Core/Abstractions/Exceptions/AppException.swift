import Foundation

class AppException : IException, CustomStringConvertible
{
    var Caused: (any Error)?
    var Message: String
    let StackTrace: [String]
    init()
    {
        Message = ""
        StackTrace = Thread.callStackSymbols
    }
    
    convenience init(_ message: String)
    {
        self.init(message, cause: nil)
    }
    
    init(_ message: String, cause: Error? = nil)
    {
        self.Message = message
        self.Caused = cause
        self.StackTrace = Thread.callStackSymbols
    }
    
    var description: String //CustomStringConvertible protocol impl
    {
        buildDescription(self)
    }
    
    func buildDescription(_ error: Error, indent: String = "") -> String
    {
        // If it's our custom error type
        if let ce = error as? AppException
        {
            var s = "\(indent)\(type(of: ce)): \(ce.Message)"
            
            // show stack trace
            for line in ce.StackTrace
            {
                s += "\n\(indent)  at \(line)"
            }

            // show caused chain
            if let cause = ce.Caused
            {
                s += "\n\(indent)Caused by:\n"
                s += buildDescription(cause, indent: indent + "  ")
            }

            return s
        }

        // Fallback for NSError or plain Swift Error
        return "\(indent)\(String(describing: error))"
    }
}

//**********This will print somethimg like:
//IOException: Failed to parse response
//  at 0   MyApp                               0x0000000100023b5c ...
//  at 1   MyApp                               0x0000000100021f9c ...
//  ...
//Caused by:
//  IOException: Failed to download file
//    at 0   MyApp                             0x0000000100023b5c ...
//    at 1   MyApp                             0x0000000100021f9c ...
//    ...
//    Caused by:
//      Error Domain=network Code=-1009 "No internet"
