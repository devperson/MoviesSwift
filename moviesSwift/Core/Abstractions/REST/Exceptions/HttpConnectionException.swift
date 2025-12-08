import Foundation

struct HttpConnectionException: IExceptionWithInner
{
    let Message: String
    let Cause: Error?

    init(message: String, cause: Error? = nil)
    {
        self.Message = message
        self.Cause = cause
    }
}
