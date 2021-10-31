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
    @Published var contentType: ResponseBodyType
    @Published var data: Data?
    @Published var startTime: Date
    @Published var endTime: Date
    
    override init() {
        self.valid = false
        self.startTime = Date()
        self.endTime = Date()
        self.contentType = .unknown
    }
    
    init(statusCode: Int?,
         contentLength: Int?,
         contentType: ResponseBodyType,
         headers: Dictionary<String, String>,
         data: Data?,
         startTime: Date,
         endTime: Date) {
        
        self.valid = true
        self.statusCode = statusCode
        self.contentLength = contentLength
        self.contentType = contentType
        self.data = data
        self.startTime = startTime
        self.endTime = endTime
        super.init()
        self.headers = headers
    }
}
