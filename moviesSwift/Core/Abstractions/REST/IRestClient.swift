import Foundation

protocol IRestClient {
    func doHttpRequest(method: RestMethod, httpRequest: RestClientHttpRequest) async throws -> String
}

struct RestClientHttpRequest {
    var requestMethod: RestMethod = .GET
    var url: String = ""
    var jsonBody: String? = nil
    var accessToken: String? = nil
    var requestTimeout: TimeoutType = .Small
}
