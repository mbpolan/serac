//
//  Response.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class Response: HTTPMessage, Codable {
    @Published var valid: Bool
    @Published var statusCode: Int?
    @Published var contentLength: Int?
    @Published var contentType: ResponseBodyType
    @Published var data: Data?
    @Published var startTime: Date
    @Published var endTime: Date
    
    enum CodingKeys: CodingKey {
        case headers
        case valid
        case statusCode
        case contentLength
        case contentType
        case data
        case startTime
        case endTime
    }
    
    override init() {
        self.valid = false
        self.startTime = Date()
        self.endTime = Date()
        self.contentType = .unknown
    }
    
    init(statusCode: Int?,
         contentLength: Int?,
         contentType: ResponseBodyType,
         headers: [KeyValuePair],
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
    
    init(from httpResponse: HTTPResponse) {
        self.valid = true
        self.statusCode = httpResponse.statusCode
        self.contentLength = httpResponse.contentLength
        self.contentType = httpResponse.contentType
        self.data = httpResponse.data
        self.startTime = httpResponse.startTime
        self.endTime = httpResponse.endTime
        super.init()
        self.headers = httpResponse.headers
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        valid = try container.decode(Bool.self, forKey: .valid)
        statusCode = try container.decodeIfPresent(Int.self, forKey: .statusCode)
        contentLength = try container.decodeIfPresent(Int.self, forKey: .contentLength)
        contentType = try container.decode(ResponseBodyType.self, forKey: .contentType)
        data = try container.decodeIfPresent(Data.self, forKey: .data)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decode(Date.self, forKey: .endTime)
        
        super.init()
        headers = try container.decode([KeyValuePair].self, forKey: .headers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(valid, forKey: .valid)
        try container.encode(statusCode, forKey: .statusCode)
        try container.encode(contentLength, forKey: .contentLength)
        try container.encode(contentType, forKey: .contentType)
        try container.encode(data, forKey: .data)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(headers, forKey: .headers)
    }
}
