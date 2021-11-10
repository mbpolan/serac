//
//  CollectionItem.swift
//  Serac
//
//  Created by Mike Polan on 11/7/21.
//

import Foundation

class CollectionItem: ObservableObject, Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    var type: ItemType
    @Published var groupName: String?
    @Published var request: Request?
    @Published var children: [CollectionItem]?
    
    static func == (lhs: CollectionItem, rhs: CollectionItem) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
    
    enum CodingKeys: CodingKey {
        case id
        case type
        case groupName
        case request
        case children
    }
    
    init(children: [CollectionItem]) {
        self.type = .root
        self.children = children
    }
    
    init(groupName: String) {
        self.type = .group
        self.groupName = groupName
    }
    
    init(request: Request) {
        self.type = .request
        self.request = request
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        type = try container.decode(ItemType.self, forKey: .type)
        groupName = try container.decodeIfPresent(String.self, forKey: .groupName)
        request = try container.decodeIfPresent(Request.self, forKey: .request)
        children = try container.decodeIfPresent([CollectionItem].self, forKey: .children)
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(groupName, forKey: .groupName)
        try container.encode(request, forKey: .request)
        try container.encode(children, forKey: .children)
    }
}

extension CollectionItem {
    enum ItemType: Codable {
        case root
        case group
        case request
    }
}
