import Foundation
import Resolver

final class AuthTokenService: LoggableService, IAuthTokenService
{

    @LazyInjected var preferencesService: IPreferences

    private static let TAG = "AuthTokenService: "
    private static let AUTH_KEY = "user_at"

    private var authToken: AuthTokenDetails? = nil

    // MARK: - IAuthTokenService

    func GetToken() async -> String?
    {
        let tokenDetails = await GetAuthTokenDetails()
        return tokenDetails?.Token ?? ""
    }

    func EnsureAuthValid() async throws
    {
        if authToken == nil
        {
            authToken = await GetAuthTokenDetails()
        }

        guard let authToken = authToken
        else
        {
            loggingService.LogWarning("\(Self.TAG)Skip checking access token because authToken is null")
            return
        }

        let expireDate = authToken.ExpiredDate
        let nowDate = Date().utcDateOnly

        guard let expireMinus2Days = Calendar.current.date(byAdding: .day, value: -2, to: expireDate)?.utcDateOnly
        else
        {
            loggingService.LogWarning("\(Self.TAG)Failed to calculate 'expiredDate - 2 days'")
            return
        }

        if expireMinus2Days < nowDate
        {
            loggingService.LogWarning("\(Self.TAG)Access token expired (expiredDate - 2days): " + "\(expireMinus2Days) < \(nowDate), actual expired: \(expireDate)")
            throw AuthExpiredException()
        }
    }

    func SaveAuthTokenDetails(_ authToken: AuthTokenDetails?) async
    {
        do
        {
            let data = try JSONEncoder().encode(authToken)
            let jsonString = String(data: data, encoding: .utf8) ?? ""
            preferencesService.Set(Self.AUTH_KEY, jsonString)
        }
        catch
        {
            loggingService.LogError(error, "\(Self.TAG)Failed to serialize AuthTokenDetails")
        }
    }

    func GetAuthTokenDetails() async -> AuthTokenDetails?
    {
        let authTokenJson = preferencesService.Get(Self.AUTH_KEY, defaultValue: "")
        guard !authTokenJson.isEmpty
        else
        {
            return nil
        }

        do
        {
            let data = Data(authTokenJson.utf8)
            return try JSONDecoder().decode(AuthTokenDetails.self, from: data)
        }
        catch
        {
            loggingService.LogError(error, "\(Self.TAG)Failed to deserialize AuthTokenDetails")
            return nil
        }
    }
}

extension Date
{
    var utcDateOnly: Date
    {
        let calendar = Calendar(identifier: .gregorian)
        var components = calendar.dateComponents(in: TimeZone(secondsFromGMT: 0)!, from: self)
        components.hour = 0
        components.minute = 0
        components.second = 0
        return calendar.date(from: components)!
    }
}
