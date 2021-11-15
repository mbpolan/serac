//
//  HTTPMessage.swift
//  Serac
//
//  Created by Mike Polan on 10/25/21.
//

import Foundation

class HTTPMessage: ObservableObject, Codable {
    @Published var headers: [KeyValuePair] = []
    
    enum CodingKeys: CodingKey {
        case headers
    }
    
    init() {
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        headers = try container.decode([KeyValuePair].self, forKey: .headers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(headers, forKey: .headers)
    }
}
