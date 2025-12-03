import Foundation

struct HttpRequestException : Error
{
    let message: String

    init(_ message: String) {
        self.message = message
    }
}
