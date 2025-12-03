import Foundation

protocol IAuthTokenService
{
    func GetToken() async -> String?
    func EnsureAuthValid() async
    func SaveAuthTokenDetails(_ authToken: AuthTokenDetails?) async
    func GetAuthTokenDetails() async -> AuthTokenDetails?
}

public struct AuthTokenDetails
{
    public let Token: String
    public let ExpiredDate: Date
    public let RefreshToken: String

    public init(Token: String, ExpiredDate: Date, RefreshToken: String) {
        self.Token = Token
        self.ExpiredDate = ExpiredDate
        self.RefreshToken = RefreshToken
    }
}
