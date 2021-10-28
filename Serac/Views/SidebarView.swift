//
//  SidebarView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct SidebarView: View {
    @EnvironmentObject private var appState: AppState
    
    var body: some View {
        List(appState.sessions) { session in
            HStack {
                Text(session.request.method.rawValue)
                
                Spacer()
                
                Text(session.request.name)
            }
            .onTapGesture {
                appState.activeSession = session
            }
        }
    }
}

// MARK: - Preview

struct SidebarView_Preview: PreviewProvider {
    static var previews: some View {
        SidebarView()
    }
}
