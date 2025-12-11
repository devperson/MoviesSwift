//
//  RestClient.swift
//  moviesSwift
//
//  Created by xasan on 07/12/25.
//


import Foundation

internal final class RestClient: LoggableService, IRestClient
{
    private let TAG = "RestClient: "

    // MARK: - Main Method

    func DoHttpRequest(_ method: RestMethod,
                       _ httpRequest: RestClientHttpRequest) async throws -> String
    {
        let timeoutMillis: Int = {
            switch httpRequest.RequestTimeout
            {
                case .Small:    return 10_000
                case .Medium:   return 30_000
                case .High:     return 60_000
                case .VeryHigh: return 120_000
            }
        }()

        guard let url = URL(string: httpRequest.Url) else
        {
            let error = RestException("\(TAG)Invalid URL: \(httpRequest.Url)")
            loggingService.LogError(error, "\(TAG)Invalid URL: \(httpRequest.Url)")
            throw error
        }

        var request = URLRequest(url: url)

        // Apply Timeout
        request.timeoutInterval = Double(timeoutMillis) / 1000.0

        // Set HTTP method
        switch method
        {
            case .GET:    request.httpMethod = "GET"
            case .POST:   request.httpMethod = "POST"
            case .PUT:    request.httpMethod = "PUT"
            case .DELETE: request.httpMethod = "DELETE"
        }

        // Default headers
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Authorization
        if let token = httpRequest.AccessToken, !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Additional optional headers
//        if let headers = httpRequest.HeaderValues {
//            for (key, value) in headers {
//                request.setValue(value, forHTTPHeaderField: key)
//            }
//        }

        // JSON Body
        if let json = httpRequest.JsonBody, !json.isEmpty {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = json.data(using: .utf8)
        }

        //loggingService.Log("\(TAG)Sending HTTP request: \(method) \(httpRequest.Url)")

        // MARK: - Execute URLSession request

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else
        {
            let error = RestException("Invalid HTTP response")
            loggingService.LogError(error, "\(TAG)No HTTPURLResponse")
            throw error
        }

        let status = httpResponse.statusCode

        //loggingService.Log("\(TAG)Response status: \(status) for \(method) \(httpRequest.Url)")

        let responseContent = String(data: data, encoding: .utf8) ?? ""

        // Success codes: 200–299 (same as typical HTTP)
        if status < 200 || status >= 300
        {
            
            let error = HttpRequestException(statusCode: status, message: responseContent)
            loggingService.LogError(error, "\(TAG)HTTP error status: \(status), body: \(responseContent)")
            throw error
        }

        return responseContent
    }
}
