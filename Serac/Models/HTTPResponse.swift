//
//  HTTPResponse.swift
//  Serac
//
//  Created by Mike Polan on 10/30/21.
//

import Foundation

struct HTTPResponse {
    let statusCode: Int
    let headers: Dictionary<String, String>
    let contentLength: Int?
    let contentType: ResponseBodyType
    let startTime: Date
    let endTime: Date
    let data: Data?
}
