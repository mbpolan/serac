//
//  Session.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class Session: ObservableObject, Identifiable {
    var id = UUID().uuidString
    
    @Published var request: Request = Request()
    @Published var response: Response = Response()
    
    init() {
    }
    
    init(id: String, request: Request) {
        self.id = id
        self.request = request
    }
}
