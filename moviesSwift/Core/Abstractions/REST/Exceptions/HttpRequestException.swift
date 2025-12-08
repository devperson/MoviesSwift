import Foundation

struct HttpRequestException: IException
{
    let Message: String
    let StatusCode: Int

    init(statusCode: Int, message: String)
    {
        self.Message = message
        self.StatusCode = statusCode
    }
}

