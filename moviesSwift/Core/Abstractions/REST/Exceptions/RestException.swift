struct RestException : IExceptionWithInner
{
    let Message: String
    var Cause: (any Error)?
    
    init(message: String)
    {
        self.Message = message
    }
    
    init(message: String, cause: any Error)
    {
        self.Message = message
        self.Cause = cause
    }
}
