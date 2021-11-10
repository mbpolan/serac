//
//  KeyValuePair.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class KeyValuePair: ObservableObject, Identifiable, Hashable, Equatable, Codable {
    var id = UUID().uuidString
    
    @Published var key: String = ""
    @Published var value: String = ""
    
    enum CodingKeys: CodingKey {
        case id
        case key
        case value
    }
    
    static func == (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
    
    init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        key = try container.decode(String.self, forKey: .key)
        value = try container.decode(String.self, forKey: .value)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(key, forKey: .key)
        try container.encode(value, forKey: .value)
    }
}
