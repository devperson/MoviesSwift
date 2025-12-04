import Foundation
import Resolver

class LoggableViewModel
{
    @LazyInjected var loggingService: ILoggingService

    func LogMethodStart(_ methodName: String, _ args: Any?...)
    {
        let className = String(describing: type(of: self))
        loggingService.LogMethodStarted(className: className, methodName: methodName, args: args.map {$0 as Any})
    }


}
