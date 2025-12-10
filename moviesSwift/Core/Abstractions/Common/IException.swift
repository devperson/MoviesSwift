struct AppException : IExceptionWithInner
{
    var Message: String
    var Cause: (any Error)?
    
    init(_ Message: String)
    {
        self.Message = Message
    }
    init(_ Message: String, Cause: (any Error)?)
    {
        self.Message = Message
        self.Cause = Cause
    }
    
    
}



protocol IException: Error
{
    var Message: String
    {
        get
    }
}

protocol IExceptionWithInner: IException
{
    var Cause: Error?
    {
        get
    }
}


