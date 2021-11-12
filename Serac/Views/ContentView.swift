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
            
            Group {
                if let activeSession = appState.activeSession {
                    SessionView(session: activeSession)
                } else {
                    SplashView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    Button(action: handleSidebar) {
                        Image(systemName: "sidebar.leading")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    TextField(text: sessionName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                ToolbarItem {
                    Spacer()
                }
                
                ToolbarItem(placement: .primaryAction) {
                    HStack {
                        if appState.activeSession != nil {
                            Button(action: handleClose) {
                                Image(systemName: "xmark")
                            }
                            .help("Close the current request")
                        }
                        
                        Button(action: handleAdd) {
                            Image(systemName: "plus")
                        }
                        .help("Create a new request")
                    }
                }
            }
        }
        .onCloseRequest(perform: handleClose)
        .onClearSessions(perform: handleClearSessions)
    }
    
    private var sessionName: Binding<String> {
        return Binding<String>(
            get: { appState.activeSession?.request.name ?? "" },
            set: {
                appState.activeSession?.request.name = $0
                appState.objectWillChange.send()
            }
        )
    }
    
    private func handleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(
            #selector(NSSplitViewController.toggleSidebar(_:)),
            with: nil)
    }
    
    private func handleAdd() {
        let request = Request()
        let session = Session(id: request.id, request: request)
        
        appState.collections.insert(CollectionItem(request: request), at: 0)
        appState.activeSession = session
        
        PersistAppStateNotification().notify()
    }
    
    private func handleClose() {
        appState.activeSession = nil
        
        PersistAppStateNotification().notify()
    }
    
    private func handleClearSessions() {
        appState.sessions = []
        appState.activeSession = nil
        
        PersistAppStateNotification().notify()
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
