//
//  HTTPMethod.swift
//  Serac
//
//  Created by Mike Polan on 10/2/21.
//

enum HTTPMethod: String, CaseIterable, Codable {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case delete = "DELETE"
    case patch = "PATCH"
}
