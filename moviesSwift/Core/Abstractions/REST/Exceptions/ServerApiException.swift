import Foundation

struct ServerApiException: IException {
    let Message: String

    init(_ message: String) {
        self.Message = message
    }
}
