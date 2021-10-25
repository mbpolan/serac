//
//  Request.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class Request: ObservableObject {
    @Published var name: String = "Untitled"
    @Published var method: HTTPMethod = .get
    @Published var url: String = ""
    @Published var headers: Dictionary<String, String> = [:]
    @Published var body: String?
}

extension Request {
    enum Header: String {
        case contentType = "Content-Type"
    }
}
