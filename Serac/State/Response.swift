//
//  Response.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class Response: HTTPMessage {
    @Published var valid: Bool
    @Published var statusCode: Int?
    @Published var contentLength: Int?
    @Published var contentType: String?
    @Published var data: Data?
    
    override init() {
        self.valid = false
    }
    
    init(statusCode: Int?,
         contentLength: Int?,
         contentType: String?,
         headers: Dictionary<String, String>,
         data: Data?) {
        
        self.valid = true
        self.statusCode = statusCode
        self.contentLength = contentLength
        self.contentType = contentType
        self.data = data
        super.init()
        self.headers = headers
    }
}
