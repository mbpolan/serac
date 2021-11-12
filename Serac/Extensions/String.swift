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
}
