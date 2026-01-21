import Foundation

protocol IAuthTokenService
{
    func GetToken() async throws -> String?
    func EnsureAuthValid() async throws
    func SaveAuthTokenDetails(_ authToken: AuthTokenDetails?) async throws
    func GetAuthTokenDetails() async throws -> AuthTokenDetails?
}

public struct AuthTokenDetails: Codable
{
    // MARK: - Properties (preserve PascalCase case)
    public let Token: String
    public let ExpiredDate: Date
    public let RefreshToken: String

    public init(Token: String, ExpiredDate: Date, RefreshToken: String)
    {
        self.Token = Token
        self.ExpiredDate = ExpiredDate
        self.RefreshToken = RefreshToken
    }

    /**
     CodingKeys are required because Swift’s Codable system expects
     lowerCamelCase names by default (`token`, `expiredDate`, etc).

     Our Kotlin model uses PascalCase (`Token`, `ExpiredDate`, `RefreshToken`)
     and we want the JSON to preserve those exact names.

     Defining CodingKeys ensures:
       - JSON encoding uses these exact keys
       - JSON decoding expects these exact keys
       - No automatic case conversion happens

     Without CodingKeys:
       Swift would try to map JSON keys using a different case style,
       and decoding would fail or produce nil values.
     */
    enum CodingKeys: String, CodingKey
    {
        case Token
        case ExpiredDate
        case RefreshToken
    }
}

