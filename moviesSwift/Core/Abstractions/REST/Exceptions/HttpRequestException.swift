import Foundation

class HttpRequestException: AppException
{
    let StatusCode: Int

    init(statusCode: Int, message: String)
    {
        self.StatusCode = statusCode
        super.init(message, cause: nil)
    }
}

