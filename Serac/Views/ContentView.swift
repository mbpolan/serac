//
//  ContentView.swift
//  Serac
//
//  Created by Mike Polan on 10/2/21.
//

import SwiftUI

// MARK: - View

struct ContentView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        NavigationView {
            SidebarView()
            
            SessionView(session: appState.activeSession)
                .toolbar {
                    ToolbarItem(placement: .navigation) {
                        Button(action: handleSidebar) {
                            Image(systemName: "sidebar.leading")
                        }
                    }
                    
                    ToolbarItem(placement: .principal) {
                        TextField("", text: $appState.activeSession.request.name)
                    }
                    
                    ToolbarItem {
                        Spacer()
                    }
                    
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: handleAdd) {
                            Image(systemName: "plus")
                        }
                    }
                }
        }
    }
    
    private func handleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)),
            with: nil)
    }
    
    private func handleAdd() {
        let session = Session()
        appState.sessions.append(session)
        appState.activeSession = session
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
