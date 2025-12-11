
protocol IException: Error
{
    var Message: String { get }
    var Caused: Error? { get }
    var StackTrace: [String] { get }
}

protocol IExceptionWithInner: IException
{
    var Cause: Error?
    {
        get
    }
}


