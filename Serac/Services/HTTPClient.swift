//
//  HTTPClient.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Combine
import Foundation

// MARK: - Responses

struct OAuth2TokenResponse: Codable {
    let accessToken: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - Errors

enum NetworkError: Error {
    case invalidURL(url: String)
    case authRequestFailed(response: HTTPResponse)
    case authRequestError(message: String)
    case requestFailed(message: String)
}

// MARK: - HTTPClient

struct HTTPClient {
    static let shared = HTTPClient()
    
    func send(_ request: Request) -> AnyPublisher<HTTPResponse, Error> {
        guard let url = URL(string: request.url) else {
            return Fail(error: NetworkError.invalidURL(url: request.url))
                .eraseToAnyPublisher()
        }
        
        return prepareAuthentication(request, to: URLRequest(url: url))
    }
    
    private func convertHTTPURLResponse(_ response: HTTPURLResponse, data: Data?, startTime: Date) -> HTTPResponse {
        let headerKeys = response.allHeaderFields.map { String(describing: $0.key).lowercased() }
        let headers = headerKeys.map {
            KeyValuePair($0, response.value(forHTTPHeaderField: $0) ?? "")
        }
        
        // extract known headers
        let contentType = response.value(forHTTPHeaderField: "Content-Type")
        
        return HTTPResponse(
            statusCode: response.statusCode,
            headers: headers,
            contentLength: data?.count,
            contentType: ResponseBodyType.parse(from: contentType),
            startTime: startTime,
            endTime: Date(),
            data: data)
    }
    
    private func sendRequest(_ request: Request,
                            authURLRequest: URLRequest) -> AnyPublisher<HTTPResponse, Error> {
        
        var urlRequest = authURLRequest
        urlRequest.httpMethod = request.method.rawValue
        
        // set header values
        request.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        if request.bodyContentType != .none {
            urlRequest.httpBody = request.body.data(using: .utf8)
            
            // if a content-type header is not present, set one automatically depending on
            // the request body
            if !request.headers.contains(where: { $0.key.lowercased() == "content-type" }) {
                switch request.bodyContentType {
                case .text:
                    urlRequest.setValue("text/plain", forHTTPHeaderField: "content-type")
                case .json:
                    urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
                case .formURLEncoded:
                    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
                default:
                    break
                }
            }
        }
        
        // mark the time the request was initiated
        let startTime = Date()
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { (data, response) in
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkError.requestFailed(message: "Invalid response")
                }
                
                return convertHTTPURLResponse(response, data: data, startTime: startTime)
            }
            .eraseToAnyPublisher()
    }
    
    private func prepareAuthentication(_ request: Request,
                                       to urlRequest: URLRequest) -> AnyPublisher<HTTPResponse, Error> {
        
        switch request.authenticationType {
        case .basic:
            let value = Data("\(request.authentication.basic.username):\(request.authentication.basic.password)".utf8).base64EncodedString()
            
            var urlRequestMutable = urlRequest
            urlRequestMutable.setValue("Basic \(value)", forHTTPHeaderField: "Authorization")
            
            return sendRequest(request, authURLRequest: urlRequestMutable)
            
        case .oauth2:
            let startTime = Date()
            let oauth2 = request.authentication.oauth2
            
            if oauth2.tokenURL.isBlank() {
                return Fail(error: NetworkError.requestFailed(message: "OAuth2 token URL is empty"))
                    .eraseToAnyPublisher()
            }
            
            guard let tokenURL = URL(string: oauth2.tokenURL) else {
                return Fail(error: NetworkError.invalidURL(url: oauth2.tokenURL))
                    .eraseToAnyPublisher()
            }
            
            var tokenRequest = URLRequest(url: tokenURL)
            tokenRequest.httpMethod = "POST"
            tokenRequest.setValue("application/json", forHTTPHeaderField: "accept")
            tokenRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
            
            var data: [KeyValuePair] = []
            if !oauth2.grantType.isEmpty {
                data.append(KeyValuePair("grant_type", oauth2.grantType))
            }
            
            if !oauth2.clientId.isEmpty {
                data.append(KeyValuePair("client_id", oauth2.clientId))
            }
            
            if !oauth2.clientSecret.isEmpty {
                data.append(KeyValuePair("client_secret", oauth2.clientSecret))
            }
            
            if !oauth2.scope.isEmpty {
                data.append(KeyValuePair("scope", oauth2.scope))
            }
            
            let body = data.map { field in
                let key = field.key
                let value = field.value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? field.value
                
                return "\(key)=\(value)"
            }.joined(separator: "&")
            
            tokenRequest.httpBody = body.data(using: .utf8)
            
            return URLSession.shared.dataTaskPublisher(for: tokenRequest)
                .tryMap { (data, response) in
                    guard let response = response as? HTTPURLResponse else {
                        throw NetworkError.authRequestError(message: "Invalid response")
                    }
                    
                    let oauth2Response = try JSONDecoder().decode(OAuth2TokenResponse.self, from: data)
                    guard let accessToken = oauth2Response.accessToken else {
                        throw NetworkError.authRequestFailed(response: convertHTTPURLResponse(response, data: data, startTime: startTime))
                    }
                    
                    var urlRequestMutable = urlRequest
                    urlRequestMutable.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    return urlRequestMutable
                }
                .flatMap { urlRequest in
                    return sendRequest(request, authURLRequest: urlRequest)
                }
                .eraseToAnyPublisher()
            
        default:
            return sendRequest(request, authURLRequest: urlRequest)
        }
    }
}
