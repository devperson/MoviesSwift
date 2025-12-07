import Foundation

struct AuthExpiredException: IException
{
    let Message: String = "user access token is expired"
}
