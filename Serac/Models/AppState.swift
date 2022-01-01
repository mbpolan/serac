//
//  AppState.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class AppState: ObservableObject, Codable {
    @Published var activeItemID: String?
    @Published var sessions: [Session]
    @Published var activeSession: Session?
    @Published var collections: [CollectionItem]
    
    enum CodingKeys: CodingKey {
        case activeItemID
        case sessions
        case activeSession
        case collections
    }
    
    init() {
        activeItemID = nil
        sessions = []
        activeSession = nil
        collections = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        activeItemID = try container.decodeIfPresent(String.self, forKey: .activeItemID)
        sessions = try container.decode([Session].self, forKey: .sessions)
        activeSession = try container.decodeIfPresent(Session.self, forKey: .activeSession)
        collections = try container.decode([CollectionItem].self, forKey: .collections)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(activeItemID, forKey: .activeItemID)
        try container.encode(sessions, forKey: .sessions)
        try container.encode(activeSession, forKey: .activeSession)
        try container.encode(collections, forKey: .collections)
    }
    
    func findRequestBy(id: String) -> Request? {
        for item in collections {
            let target = findRequestBy(id: id, under: item)
            if target != nil {
                return target
            }
        }
        
        return nil
    }
    
    private func findRequestBy(id: String, under item: CollectionItem) -> Request? {
        switch item.type {
        case .request:
            return item.id == id ? item.request : nil
        case .group, .root:
            guard let children = item.children else { return nil }
            
            for child in children {
                let target = findRequestBy(id: id, under: child)
                if target != nil {
                    return target
                }
            }
            
            return nil
        }
    }
}

extension AppState {
    
    private func getSaveFile() throws -> URL {
        let url = try FileManager.default.url(for: .documentDirectory,
                                                 in: .userDomainMask,
                                                 appropriateFor: nil,
                                                 create: false)
        
        return url.appendingPathComponent("serac.json")
    }
    
    func load() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            do {
                guard let self = self else { return }
                let data = try JSONDecoder().decode(AppState.self, from: Data(contentsOf: self.getSaveFile()))
                
                // update each session to have the same request instance as the one it came from
                // this avoids desyncing when someone updates a property on a session and it does not get
                // reflected in the original request
                data.sessions = data.sessions.map { session in
                    if let request = data.findRequestBy(id: session.id) {
                        session.request = request
                    } else {
                        print("WARN: could not find matching request for session \(session.id)")
                    }
                    
                    return session
                }
                
                // refresh the active session afterwards
                if let activeID = data.activeSession?.id {
                    data.activeSession = data.sessions.first { $0.id == activeID }
                }
                
                DispatchQueue.main.async {
                    self.sessions = data.sessions
                    self.activeSession = data.activeSession
                    self.collections = data.collections
                }
            } catch {
                print("Failed to load data: \(error)")
            }
        }
    }
    
    func save() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            do {
                guard let self = self else { return }
                let data = try JSONEncoder().encode(self)
                
                try data.write(to: self.getSaveFile())
            } catch {
                print("Failed to save data: \(error)")
            }
        }
    }
}
