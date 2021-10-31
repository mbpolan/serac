//
//  HTTPClient.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

struct HTTPClient {
    static let shared = HTTPClient()
    
    func send(_ request: Request, completionHandler: @escaping(_ result: Result<HTTPResponse, Error>) -> Void) {
        guard let url = URL(string: request.url) else {
            return
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        
        // set header values
        request.headers.forEach { (key, value) in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        if let body = request.body {
            urlRequest.httpBody = body.data(using: .utf8)
        }
        
        // mark the time the request was initiated
        let startTime = Date()
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if let error = error {
                completionHandler(.failure(error))
            } else if let response = response as? HTTPURLResponse {
                let headerKeys = response.allHeaderFields.map { String(describing: $0.key).lowercased() }
                let headers = Dictionary(uniqueKeysWithValues: headerKeys.map {
                    ($0, response.value(forHTTPHeaderField: $0) ?? "")
                })
                
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
        }.resume()
    }
}
