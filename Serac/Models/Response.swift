//
//  Response.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

struct Response {
    var statusCode: Int?
    var contentLength: Int?
    var headers: Dictionary<String, String> = [:]
    var data: Data?
}
