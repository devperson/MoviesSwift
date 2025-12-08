struct AppServiceException: IException
{
    let Message: String

    init(_ message: String)
    {
        self.Message = message
    }
}

