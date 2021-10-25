//
//  RequestBodyType.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

enum RequestBodyType: String, CaseIterable {
    case `none` = "None"
    case raw = "Raw"
    case json = "JSON"
    case formURLEncoded = "Form (URL Encoded)"
}
