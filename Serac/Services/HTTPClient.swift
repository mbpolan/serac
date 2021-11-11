//
//  HTTPClient.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

struct HTTPClient {
    static let shared = HTTPClient()
    
    func send(_ request: Request, completionHandler: @escaping(_ result: Result<HTTPResponse, Error>) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: request.url) else {
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // set header values
        request.headers.forEach { header in
            urlRequest.setValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // apply authentication
        switch request.authenticationType {
        case .basic:
            let value = Data("\(request.authentication.basic.username):\(request.authentication.basic.password)".utf8).base64EncodedString()
            urlRequest.setValue("Basic \(value)", forHTTPHeaderField: "Authorization")
        default:
            break
        }
        
        if request.bodyContentType != .none {
            urlRequest.httpBody = request.body.data(using: .utf8)
            
            // if a content-type header is not present, set one automatically depending on
            // the request body
            if !request.headers.contains(where: { $0.key.lowercased() == "content-type" }) {
                switch request.bodyContentType {
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
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else if let response = response as? HTTPURLResponse {
                let headerKeys = response.allHeaderFields.map { String(describing: $0.key).lowercased() }
                let headers = headerKeys.map {
                    KeyValuePair($0, response.value(forHTTPHeaderField: $0) ?? "")
                }
                
                // extract known headers
                let contentType = response.value(forHTTPHeaderField: "Content-Type")
                
                let response = HTTPResponse(
                    statusCode: response.statusCode,
                    headers: headers,
                    contentLength: data?.count,
                    contentType: ResponseBodyType.parse(from: contentType),
                    startTime: startTime,
                    endTime: Date(),
                    data: data)
                
                completionHandler(.success(response))
            }
        }
        
        task.resume()
        return task
    }
}
