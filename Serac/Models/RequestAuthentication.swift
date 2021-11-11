//
//  RequestAuthentication.swift
//  Serac
//
//  Created by Mike Polan on 11/10/21.
//

import Foundation

class RequestAuthentication: ObservableObject, Codable {
    @Published var basic: BasicRequestAuthentication = BasicRequestAuthentication()
    
    enum CodingKeys: CodingKey {
        case basic
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.basic = try container.decode(BasicRequestAuthentication.self, forKey: .basic)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(basic, forKey: .basic)
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
