//
//  SeracApp.swift
//  Serac
//
//  Created by Mike Polan on 10/2/21.
//

import SwiftUI

@main
struct SeracApp: App {
    private let appState: AppState
    
    init() {
        self.appState = AppState()
        self.appState.load()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onPersistAppState {
                    appState.save()
                }
        }
        .windowToolbarStyle(UnifiedCompactWindowToolbarStyle())
        .commands {
            AppCommands()
            SidebarCommands()
        }
        
        Settings {
            SettingsView()
        }
    }
}
