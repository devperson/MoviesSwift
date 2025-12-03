import Foundation

struct AuthExpiredException: Error {
    let message: String = "user access token is expired"
}
