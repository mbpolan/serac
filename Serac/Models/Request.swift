//
//  Request.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class Request: HTTPMessage, Codable {
    var id: String = UUID().uuidString
    
    @Published var name: String = "Untitled"
    @Published var method: HTTPMethod = .get
    @Published var url: String = ""
    @Published var body: String?
    @Published var bodyContentType: RequestBodyType = .none
    @Published var authentication: RequestAuthentication = RequestAuthentication()
    @Published var authenticationType: RequestAuthenticationType = .none
    
    enum CodingKeys: CodingKey {
        case name
        case method
        case url
        case body
        case bodyContentType
        case authentication
        case authenticationType
    }
    
    override init() {
    }
    
    required init(from decoder: Decoder) throws {
        super.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        name = try container.decode(String.self, forKey: .name)
        method = try container.decode(HTTPMethod.self, forKey: .method)
        url = try container.decode(String.self, forKey: .url)
        body = try container.decodeIfPresent(String.self, forKey: .body)
        bodyContentType = try container.decode(RequestBodyType.self, forKey: .bodyContentType)
        authentication = try container.decode(RequestAuthentication.self, forKey: .authentication)
        authenticationType = try container.decode(RequestAuthenticationType.self, forKey: .authenticationType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(name, forKey: .name)
        try container.encode(method, forKey: .method)
        try container.encode(url, forKey: .url)
        try container.encode(body, forKey: .body)
        try container.encode(bodyContentType, forKey: .bodyContentType)
        try container.encode(authentication, forKey: .authentication)
        try container.encode(authenticationType, forKey: .authenticationType)
    }
}
