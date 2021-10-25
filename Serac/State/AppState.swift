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
    
    init() {
        let session = Session()
        sessions = [session]
        activeSession = session
    }
}
