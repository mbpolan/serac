//
//  Request.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class Request: HTTPMessage {
    var id: String = UUID().uuidString
    
    @Published var name: String = "Untitled"
    @Published var method: HTTPMethod = .get
    @Published var url: String = ""
    @Published var body: String?
    @Published var bodyContentType: RequestBodyType = .none
}
