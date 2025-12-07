import Foundation

protocol IRestClient
{
    func DoHttpRequest(_ method: RestMethod, _ httpRequest: RestClientHttpRequest) async throws -> String
}

struct RestClientHttpRequest
{
    var RequestMethod: RestMethod = .GET
    var Url: String = ""
    var JsonBody: String? = nil
    var AccessToken: String? = nil
    var RequestTimeout: TimeoutType = .Small
}
