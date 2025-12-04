import Foundation

struct HttpRequestException : Error
{
    let message: String
    let statusCode: Int
    
    init(statusCode: Int, message: String)
    {
        self.message = message
        self.statusCode = statusCode
    }
}

