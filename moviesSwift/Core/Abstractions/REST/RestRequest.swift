import Foundation

struct RestRequest
{
    var ApiEndpoint: String
    var RequestPriority: Priority = .High
    var RequestTimeout: TimeoutType = .Small
    var CancelSameRequest: Bool = false
    var WithBearer: Bool = true
    var RequestBody: String? = nil
    var RetryCount: Int = 0
    var HeaderValues: [String: String]? = nil

    init(apiEndpoint: String,
         requestPriority: Priority = .High,
         requestTimeout: TimeoutType = .Small,
         cancelSameRequest: Bool = false,
         withBearer: Bool = true,
         requestBody: String? = nil,
         retryCount: Int = 0,
         headerValues: [String: String]? = nil) {
        self.ApiEndpoint = apiEndpoint
        self.RequestPriority = requestPriority
        self.RequestTimeout = requestTimeout
        self.CancelSameRequest = cancelSameRequest
        self.WithBearer = withBearer
        self.RequestBody = requestBody
        self.RetryCount = retryCount
        self.HeaderValues = headerValues
    }
}
