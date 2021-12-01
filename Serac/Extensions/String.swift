//
//  String.swift
//  Serac
//
//  Created by Mike Polan on 11/11/21.
//

extension String {
    func isBlank() -> Bool {
        return allSatisfy({ $0.isWhitespace })
    }
    
    func contains(caseInsensitive other: String) -> Bool {
        return self.range(of: other, options: .caseInsensitive) != nil
    }
}
