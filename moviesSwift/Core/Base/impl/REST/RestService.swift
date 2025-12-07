//
//  RestService.swift
//  moviesSwift
//
//  Created by xasan on 08/12/25.
//


import Foundation
import Resolver

open class RestService: LoggableService
{
    @LazyInjected var authTokenService: IAuthTokenService
    @LazyInjected var restClient: IRestClient
    @LazyInjected var eventAggregator: IMessagesCenter
    @LazyInjected var queueList: RequestQueueList
    @LazyInjected var constants: IConstant

    private let tag = "RestClientService: "

    // JSON serializers
    // (tuned to behave similarly to Kotlinx Json settings)
    let jsonDecoder: JSONDecoder = {
        let d = JSONDecoder()
        // customize if needed (date decoding, key strategies, etc.)
        return d
    }()

    let jsonEncoder: JSONEncoder = {
        let e = JSONEncoder()
        e.outputFormatting = [.prettyPrinted]
        return e
    }()

    // MARK: - Public REST API

    // Kotlin: suspend inline fun <reified T> Get(restRequest: RestRequest): T
    func Get<T: Decodable>(_ type: T.Type, _ restRequest: RestRequest) async throws -> T
    {
        LogMethodStart(#function, restRequest)
        return try await WithApiErrorHandling
        {
            try await self.MakeWebRequest(type, .GET, restRequest)
        }
    }

    // Kotlin: suspend inline fun <reified T> Post(restRequest: RestRequest): T
    func Post<T: Decodable>(_ type: T.Type, _ restRequest: RestRequest) async throws -> T
    {
        LogMethodStart(#function, restRequest)
        return try await WithApiErrorHandling
        {
            try await self.MakeWebRequest(type, .POST, restRequest)
        }
    }

    // Kotlin: suspend inline fun <reified T> Put(restRequest: RestRequest)
    // In Kotlin this usually ignores the body result. We'll just fire the request.
    func Put(_ restRequest: RestRequest) async throws
    {
        LogMethodStart(#function, restRequest)
        _ = try await WithApiErrorHandling
        {
            // If server returns JSON but you don't care about it, we can just use String or some EmptyResponse.
            try await self.MakeWebRequest(String.self, .PUT, restRequest)
        }
    }

    // Kotlin: suspend inline fun <reified T> Delete(restRequest: RestRequest): Any
    func Delete<T: Decodable>(_ type: T.Type, _ restRequest: RestRequest) async throws -> T
    {
        LogMethodStart(#function, restRequest)
        return try await WithApiErrorHandling
        {
            try await self.MakeWebRequest(type, .DELETE, restRequest)
        }
    }

    // MARK: - Core Web Request

    // Kotlin: suspend inline fun <reified T> MakeWebRequest(method: RestMethod, restRequest: RestRequest): T
    func MakeWebRequest<T: Decodable>(_ type: T.Type, _ method: RestMethod, _ restRequest: RestRequest) async throws -> T
    {

        if restRequest.WithBearer
        {
            try await authTokenService.EnsureAuthValid()
        }

        let task = AddRequestToQueue(method, restRequest)        // Task<String, Error>
        let requestResult = try await task.value                 // string content

        return try Deserialize(type, requestResult)
    }

    // Kotlin: fun AddRequestToQueue(...): Deferred<String>
    func AddRequestToQueue(_ method: RestMethod, _ restRequest: RestRequest) -> Task<String, Error>
    {
        let path = GetUrlWithoutParam(restRequest.ApiEndpoint)
        let queueItemId = "\(method)\(path)/\(restRequest.RequestPriority)/\(restRequest.CancelSameRequest)"

        Log("Request \(method): \(queueItemId), priority: \(restRequest.RequestPriority) added to Queue")

        let item = RequestQueueItem()
        item.Id = queueItemId
        item.priority = restRequest.RequestPriority
        item.timeoutType = restRequest.RequestTimeout
        item.parentList = queueList
        item.logger = self.loggingService

        // Suspend lambda: suspend () -> String in Kotlin => () async throws -> String in Swift
        item.RequestAction = { [weak self] in
            guard let self = self
            else
            {
                return ""
            }

            let fullUrl = "\(self.constants.ServerUrlHost)\(restRequest.ApiEndpoint)"
            let token = await self.authTokenService.GetToken()

            var jsonBody: String? = nil
            if let body = restRequest.RequestBody
            {
                // Assuming RequestBody: Encodable
                do
                {
                    let data = try self.jsonEncoder.encode(body)
                    jsonBody = String(data: data, encoding: .utf8)
                }
                catch
                {
                    // If body serialization fails, you may want to log it and rethrow as ServerApiException/RestException
                    self.loggingService.LogError(error, "\(self.tag)Failed to serialize request body")
                    throw RestException(message: "Failed to serialize request body", cause: error)
                }
            }

            // Build RestClientHttpRequest
            var httpRequest = RestClientHttpRequest()
            httpRequest.Url = fullUrl
            httpRequest.RequestMethod = method
            httpRequest.JsonBody = jsonBody
            httpRequest.AccessToken = token

            // Log request start
            let requestSummary: String
            if let body = httpRequest.JsonBody, !body.isEmpty
            {
                requestSummary = "DoHttpRequest(\(httpRequest.RequestMethod), \(httpRequest.Url), \(body))"
            }
            else
            {
                requestSummary = "DoHttpRequest(\(httpRequest.RequestMethod), \(httpRequest.Url))"
            }

            self.loggingService.LogMethodStarted(requestSummary)

            let responseContent = try await self.restClient.DoHttpRequest(method, httpRequest)

            // hide sensitivity data from logger
            let contentForLog = self.HideSensitiveData(responseContent)
            // log that request is finished
            self.loggingService.LogMethodFinished("\(requestSummary) with result: \(contentForLog)")

            return responseContent
        }

        queueList.add(item)

        // Use TaskCompletionSource from RequestQueueItem
        return item.CompletionSource.task
    }

    // MARK: - Deserialize / Error detection

    // Kotlin: inline fun <reified T> Deserialize(jsonStr: String): T
    func Deserialize<T: Decodable>(_ type: T.Type, _ jsonStr: String) throws -> T
    {
        try CheckForError(jsonStr)

        guard let data = jsonStr.data(using: .utf8)
        else
        {
            throw RestException(message: "Failed to convert JSON string to Data, jsonStr: \(jsonStr)")
        }

        do
        {
            return try jsonDecoder.decode(T.self, from: data)
        }
        catch
        {
            // you may choose to wrap into ServerApiException/RestException
            throw RestException(message: "Failed to deserialize JSON response, internal error: \(error.localizedDescription)", cause: error)
        }
    }

    // Kotlin: open fun CheckForError(jsonStr: String)
    open func CheckForError(_ jsonStr: String) throws
    {
        // detect "error:" marker in JSON
        if jsonStr.range(of: "error:", options: .caseInsensitive) != nil
        {
            guard let data = jsonStr.data(using: .utf8), let obj = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], let error = obj["error"] as? String
            else
            {
                return
            }
            throw ServerApiException(error)
        }
    }

    // MARK: - Error handling wrapper

    // Kotlin: suspend fun <T> WithApiErrorHandling(block: suspend () -> T): T
    func WithApiErrorHandling<T>(_ block: @escaping () async throws -> T) async throws -> T
    {
        do
        {
            return try await block()
        }
        catch let ex as AuthExpiredException
        {
            // same as Kotlin: publish event and rethrow
            let authErrorEvent = eventAggregator.GetEvent { AuthErrorEvent() }
            authErrorEvent.Publish(nil)
            throw ex
        }
        catch let ex as HttpRequestException
        {
            // Map 401 → AuthErrorEvent
            if ex.StatusCode == 401
            {
                let authErrorEvent = eventAggregator.GetEvent { AuthErrorEvent() }
                authErrorEvent.Publish(nil)
            }
            throw ex
        }
        catch let urlError as URLError
        {
            // This is what URLSession.shared.data(for:) will throw.
            // Map URLError → HttpConnectionException (internet issue).
            switch urlError.code
            {
                case .timedOut:
                    throw HttpConnectionException(message: "Request timed out", cause: urlError)
                case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                    throw HttpConnectionException(message: "Cannot resolve host", cause: urlError)
                case .notConnectedToInternet, .networkConnectionLost:
                    throw HttpConnectionException(message: "Network error: \(urlError.localizedDescription)", cause: urlError)
                default:
                    throw HttpConnectionException(message: "Network error: \(urlError.localizedDescription)", cause: urlError)
            }
        }
        catch
        {
            // Unknown / unexpected error – wrap as connection-level by default
            throw HttpConnectionException(message: "Unexpected error: \(error.localizedDescription)", cause: error)
        }
    }

    // MARK: - Helpers

    // Kotlin: private fun GetUrlWithoutParam(url: String): String
    private func GetUrlWithoutParam(_ url: String) -> String
    {
        let hasQuery = url.contains("?")
        let urlWithoutParam = hasQuery ? url.components(separatedBy: "?").first ?? url : url
        let parts = urlWithoutParam.components(separatedBy: "/")

        let count = hasQuery ? parts.count : max(parts.count - 1, 0)

        var newUrl = ""
        for i in 0..<count
        {
            let seg = parts[i]
            if !seg.isEmpty
            {
                newUrl.append("/\(seg)")
            }
        }
        return newUrl
    }

    private func Log(_ message: String)
    {
        loggingService.Log("\(tag)\(message)")
    }

    
    // Kotlin: HideSensitiveData
    private func HideSensitiveData(_ data: String) -> String
    {
        if data.contains("access_token")
        {
            // In Kotlin, you keep full content in DEBUG and strip in RELEASE.
            // For now we always strip sensitive keys (you can gate on a DEBUG flag).
            do
            {
                guard let jsonData = data.data(using: .utf8), var dict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]
                else
                {
                    return data
                }

                let sensitiveKeys = ["access_token", "userName", "phoneNumber", "token_type", ".issued", ".expires", "expires_in"]

                for key in sensitiveKeys
                {
                    dict.removeValue(forKey: key)
                }

                let cleanedData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                return String(data: cleanedData, encoding: .utf8) ?? data
            }
            catch
            {
                return data
            }
        }
        return data
    }
}
