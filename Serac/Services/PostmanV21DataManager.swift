//
//  PostmanV21Importer.swift
//  Serac
//
//  Created by Mike Polan on 11/12/21.
//

import Foundation

// MARK: - Models

fileprivate struct Root: Decodable {
    let info: FileInfo
    let item: [NodeItem]
}

fileprivate struct FileInfo: Decodable {
    let name: String
}

fileprivate struct NodeItem: Decodable {
    let name: String
    let item: [NodeItem]?
    let request: RequestInfo?
}

fileprivate struct RequestInfo: Decodable {
    let method: RequestMethodInfo
    let header: [RequestHeaderInfo]
    let url: RequestURLInfo?
    let body: RequestBodyInfo?
}

fileprivate struct RequestHeaderInfo: Decodable {
    let key: String
    let value: String
    let type: String
}

fileprivate struct RequestURLInfo: Decodable {
    let raw: String
}

fileprivate struct RequestBodyInfo: Decodable {
    let mode: RequestBodyModeInfo
    let raw: String?
    let formData: [FormDataInfo]?
    let options: RequestBodyOptionsInfo
    
    enum CodingKeys: String, CodingKey {
        case mode
        case raw
        case formData = "formdata"
        case options
    }
}

fileprivate struct FormDataInfo: Decodable {
    let key: String
    let value: String
    let type: String
}

fileprivate enum RequestBodyModeInfo: String, Decodable {
    case raw = "raw"
    case urlEncoded = "urlencoded"
    case formData = "formdata"
    case file = "file"
    case graphQL = "graphql"
}

fileprivate struct RequestBodyOptionsInfo: Decodable {
    let raw: RequestBodyOptionsRawInfo?
}

fileprivate struct RequestBodyOptionsRawInfo: Decodable {
    let language: String
}

fileprivate enum RequestMethodInfo: String, Decodable {
    case get = "GET"
    case put = "PUT"
    case post = "POST"
    case patch = "PATCH"
    case delete = "DELETE"
    case copy = "COPY"
    case head = "HEAD"
    case options = "OPTIONS"
    case link = "LINK"
    case unlink = "UNLINK"
    case purge = "PURGE"
    case lock = "LOCK"
    case unlock = "UNLOCK"
    case propfind = "PROPFIND"
    case view = "VIEW"
}

// MARK: - PostmanV21DataManager

struct PostmanV21DataManager: DataImporter {
    static let shared = PostmanV21DataManager()
    
    func load(contentsOf url: URL) -> Result<[CollectionItem], DataImportError> {
        do {
            let json = try JSONDecoder().decode(Root.self, from: Data(contentsOf: url))
            
            let root = CollectionItem(groupName: json.info.name)
            root.children = json.item.compactMap { transformNode($0) }
            
            return .success([root])
        } catch {
            print(error)
            return .failure(DataImportError.invalidFileFormat(
                description: "Unable to import collection",
                reason: error.localizedDescription,
                recovery: "Check if the file you selected is a valid Postman Collection v2.1"))
        }
    }
    
    private func transformNode(_ node: NodeItem) -> CollectionItem? {
        // does this node have children?
        if let items = node.item {
            let item = CollectionItem(groupName: node.name)
            item.children = items.compactMap { transformNode($0) }
            
            return item
        } else if let requestInfo = node.request {
            let request = Request()
            request.name = node.name
            request.url = requestInfo.url?.raw ?? ""
            
            switch requestInfo.method {
            case .get:
                request.method = .get
            case .put:
                request.method = .put
            case .post:
                request.method = .post
            case .patch:
                request.method = .patch
            case .delete:
                request.method = .delete
            case .head:
                request.method = .head
            case .options:
                request.method = .options
            default:
                request.method = .get
            }
            
            if let body = requestInfo.body {
                switch body.mode {
                case .raw:
                    if let data = transformRawBody(body) {
                        request.body = data.0
                        request.bodyContentType = data.1
                    }
                default:
                    print("WARN: unsupported request body mode: \(body.mode.rawValue)")
                }
            }
            
            return CollectionItem(request: request)
        } else {
            return nil
        }
    }
    
    private func transformRawBody(_ body: RequestBodyInfo) -> (String, RequestBodyType)? {
        guard let language = body.options.raw?.language else {
            return nil
        }
        
        switch language {
        case "json":
            return (body.raw ?? "", .json)
        case "text":
            return (body.raw ?? "", .text)
        default:
            return nil
        }
    }
}
