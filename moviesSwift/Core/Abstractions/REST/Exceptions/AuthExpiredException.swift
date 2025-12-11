import Foundation

class AuthExpiredException: AppException
{
    //override let Message: String = "user access token is expired"
    override init()
    {
        super.init()
        Message = "user access token is expired"
    }
}
