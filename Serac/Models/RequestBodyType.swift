//
//  RequestBodyType.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

enum RequestBodyType: CaseIterable, Codable {
    case `none`
    case text
    case json
    case formURLEncoded
}
