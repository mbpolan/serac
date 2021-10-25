//
//  Request.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class Request: ObservableObject {
    var name: String = "Untitled"
    var method: HTTPMethod = .get
    var url: String = ""
    var headers: Dictionary<String, String> = [:]
    var body: String?
}

extension Request {
    enum Header: String {
        case contentType = "Content-Type"
    }
}
