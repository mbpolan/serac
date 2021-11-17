//
//  ContentView.swift
//  Serac
//
//  Created by Mike Polan on 10/2/21.
//

import SwiftUI

// MARK: - View

struct ContentView: View {
    @AppStorage("variableSets") private var variableSets: [VariableSet] = []
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: ContentViewModel = ContentViewModel()
    
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
                        // show a picker for choosing the current variable set
                        Picker(selection: $appState.variableSet, label: Text("Variable Set")) {
                            Text("No Variables")
                                .tag(nil as String?)
                            
                            if variableSets.count > 0 {
                                Divider()
                            }
                            
                            ForEach(variableSets, id: \.id) { vs in
                                Text(vs.name)
                                    .tag(vs.id as String?)
                            }
                        }
                        
                        // show a close button to destroy the current session
                        if appState.activeSession != nil {
                            Button(action: handleClose) {
                                Image(systemName: "xmark")
                            }
                            .help("Close the current request")
                        }
                        
                        // show a button to quickly add a new session
                        Button(action: handleAdd) {
                            Image(systemName: "plus")
                        }
                        .help("Create a new request")
                    }
                }
            }
            .alert(isPresented: $viewModel.alertShown) {
                Alert(title: Text("Something went wrong!"),
                      message: Text(viewModel.error?.errorDescription ?? "An unknown error has occurred"),
                      dismissButton: .default(Text("OK")))
            }
        }
        .onCloseRequest(perform: handleClose)
        .onClearSessions(perform: handleClearSessions)
        .onImportData(perform: handleImportData)
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
    
    private func handleImportData(_ type: ImportDataNotification.SourceDataType) {
        switch type {
        case .postmanCollectionV21:
            handleImportPostmanCollectionV21()
        }
    }
    
    private func handleImportPostmanCollectionV21() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.json]
        panel.message = "Choose the Postman Collection v2.1 to import"
        
        if panel.runModal() == .OK,
           let url = panel.url {
            let result = PostmanV21DataManager.shared.load(contentsOf: url)
            
            switch result {
            case .success(let data):
                appState.collections.append(contentsOf: data)
            case .failure(let error):
                viewModel.alertShown = true
                viewModel.error = AppError.dataImportError(error: error)
            }
        }
    }
}

// MARK: - View Model

class ContentViewModel: ObservableObject {
    @Published var alertShown: Bool = false
    @Published var error: AppError?
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
    }
}
