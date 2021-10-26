//
//  HTTPMessage.swift
//  Serac
//
//  Created by Mike Polan on 10/25/21.
//

import Foundation

class HTTPMessage: ObservableObject {
    @Published var headers: Dictionary<String, String> = [:]
}
