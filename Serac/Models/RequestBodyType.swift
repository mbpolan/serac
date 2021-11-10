//
//  RequestBodyType.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

enum RequestBodyType: CaseIterable, Codable {
    case `none`
    case raw
    case json
    case formURLEncoded
}
