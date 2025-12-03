import Foundation

struct ServerApiException: Error {
    let message: String

    init(_ message: String) {
        self.message = message
    }
}
