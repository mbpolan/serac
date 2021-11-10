//
//  Session.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class Session: ObservableObject, Identifiable, Codable {
    var id = UUID().uuidString
    
    @Published var request: Request = Request()
    @Published var response: Response = Response()
    
    enum CodingKeys: CodingKey {
        case id
        case request
        case response
    }
    
    init() {
    }
    
    init(id: String, request: Request) {
        self.id = id
        self.request = request
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        request = try container.decode(Request.self, forKey: .request)
        response = try container.decode(Response.self, forKey: .response)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(request, forKey: .request)
        try container.encode(response, forKey: .response)
    }
}
