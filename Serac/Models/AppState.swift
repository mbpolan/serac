//
//  AppState.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation

class AppState: ObservableObject, Codable {
    @Published var sessions: [Session]
    @Published var activeSession: Session?
    @Published var collections: [CollectionItem]
    
    enum CodingKeys: CodingKey {
        case sessions
        case activeSession
        case collections
    }
    
    init() {
        sessions = []
        activeSession = nil
        collections = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        sessions = try container.decode([Session].self, forKey: .sessions)
        activeSession = try container.decodeIfPresent(Session.self, forKey: .activeSession)
        collections = try container.decode([CollectionItem].self, forKey: .collections)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(sessions, forKey: .sessions)
        try container.encode(activeSession, forKey: .activeSession)
        try container.encode(collections, forKey: .collections)
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
