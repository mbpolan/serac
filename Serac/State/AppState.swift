//
//  AppState.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class AppState: ObservableObject {
    @Published var sessions: [Session]
    @Published var activeSession: Session
    @Published var collections: [CollectionItem]
    
    init() {
        let session = Session()
        sessions = [session]
        activeSession = session
        collections = []
    }
}

class CollectionItem: ObservableObject, Identifiable, Hashable {
    var id: String = UUID().uuidString
    var type: ItemType
    @Published var groupName: String?
    @Published var request: Request?
    @Published var children: [CollectionItem]?
    
    init() {
        self.type = .root
    }
    
    init(groupName: String) {
        self.type = .group
        self.groupName = groupName
    }
    
    init(request: Request) {
        self.type = .request
        self.request = request
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: CollectionItem, rhs: CollectionItem) -> Bool {
        return lhs.id == rhs.id && lhs.type == rhs.type
    }
}

extension CollectionItem {
    enum ItemType {
        case root
        case group
        case request
    }
}
