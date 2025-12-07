protocol IException : Error
{
    var Message: String { get }
}

protocol IExceptionWithInner : IException
{
    var Cause: Error? { get }
}


