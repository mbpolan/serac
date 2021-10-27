//
//  ResponseBodyType.swift
//  Serac
//
//  Created by Mike Polan on 10/26/21.
//

enum ResponseBodyType {
    case none
    case unknown
    case json
}

extension ResponseBodyType {
    static func parse(from contentType: String?) -> ResponseBodyType {
        let type = contentType?.split(separator: ";").first?.lowercased()
        
        switch type {
        case .some("application/json"):
            return .json
        case .none:
            return .none
        default:
            return .unknown
        }
    }
}
