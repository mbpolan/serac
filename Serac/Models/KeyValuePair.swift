//
//  KeyValuePair.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class KeyValuePair: ObservableObject, Identifiable, Hashable, Equatable {
    var id = UUID().uuidString
    
    @Published var key: String = ""
    @Published var value: String = ""
    
    static func == (lhs: KeyValuePair, rhs: KeyValuePair) -> Bool {
        return lhs.key == rhs.key && lhs.value == rhs.value
    }
    
    init(_ key: String, _ value: String) {
        self.key = key
        self.value = value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
