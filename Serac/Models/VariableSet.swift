//
//  VariableSet.swift
//  Serac
//
//  Created by Mike Polan on 11/15/21.
//

import Foundation

class VariableSet: ObservableObject, Identifiable, Codable {
    static let empty = VariableSet(name: "")
    
    var id: String = UUID().uuidString
    @Published var name: String
    @Published var variables: [KeyValuePair]
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case variables
    }
    
    init(name: String) {
        self.name = name
        self.variables = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.variables = try container.decode([KeyValuePair].self, forKey: .variables)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(variables, forKey: .variables)
    }
    
    func apply(to str: String) -> String {
        return variables.reduce(str) { memo, variable in
            return memo.replacingOccurrences(of: "${\(variable.key)}", with: variable.value)
        }
    }
}
