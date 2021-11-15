//
//  RequestAuthentication.swift
//  Serac
//
//  Created by Mike Polan on 11/10/21.
//

import Foundation

class RequestAuthentication: ObservableObject, Codable {
    @Published var basic: BasicRequestAuthentication = BasicRequestAuthentication()
    @Published var oauth2: OAuth2RequestAuthentication = OAuth2RequestAuthentication()
    @Published var bearer: BearerTokenAuthentication = BearerTokenAuthentication()
    
    enum CodingKeys: CodingKey {
        case basic
        case bearer
        case oauth2
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.basic = try container.decode(BasicRequestAuthentication.self, forKey: .basic)
        self.bearer = try container.decode(BearerTokenAuthentication.self, forKey: .bearer)
        self.oauth2 = try container.decode(OAuth2RequestAuthentication.self, forKey: .oauth2)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(basic, forKey: .basic)
        try container.encode(bearer, forKey: .bearer)
        try container.encode(oauth2, forKey: .oauth2)
    }
}

class BearerTokenAuthentication: ObservableObject, Codable {
    @Published var token: String = ""
    
    enum CodingKeys: CodingKey {
        case token
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.token = try container.decode(String.self, forKey: .token)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(token, forKey: .token)
    }
}

class BasicRequestAuthentication: ObservableObject, Codable {
    @Published var username: String = ""
    @Published var password: String = ""
    
    enum CodingKeys: CodingKey {
        case username
        case password
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.username = try container.decode(String.self, forKey: .username)
        self.password = try container.decode(String.self, forKey: .password)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
    }
}

class OAuth2RequestAuthentication: ObservableObject, Codable {
    @Published var tokenURL: String = ""
    @Published var clientId: String = ""
    @Published var clientSecret: String = ""
    @Published var scope: String = ""
    @Published var grantType: String = ""
    
    enum CodingKeys: CodingKey {
        case tokenURL
        case clientId
        case clientSecret
        case scopes
        case grantType
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.tokenURL = try container.decode(String.self, forKey: .tokenURL)
        self.clientId = try container.decode(String.self, forKey: .clientId)
        self.clientSecret = try container.decode(String.self, forKey: .clientSecret)
        self.scope = try container.decode(String.self, forKey: .scopes)
        self.grantType = try container.decode(String.self, forKey: .grantType)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(tokenURL, forKey: .tokenURL)
        try container.encode(clientId, forKey: .clientId)
        try container.encode(clientSecret, forKey: .clientSecret)
        try container.encode(scope, forKey: .scopes)
        try container.encode(grantType, forKey: .grantType)
    }
}
