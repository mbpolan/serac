//
//  Array.swift
//  Serac
//
//  Created by Mike Polan on 11/15/21.
//

import Foundation

// based on: https://stackoverflow.com/a/62563773/5190023

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data) else {
                  return nil
              }
        
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8) else {
                  return "[]"
              }
        
        return result
    }
}
