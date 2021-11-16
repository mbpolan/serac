//
//  SettingsView.swift
//  Serac
//
//  Created by Mike Polan on 11/16/21.
//

import SwiftUI

// MARK: - View

struct SettingsView: View {
    @StateObject private var viewModel: SettingsViewModel = SettingsViewModel()
    
    var body: some View {
        TabView {
            VariableSettingsView()
                .tabItem { Label("Variables", systemImage: "folder.badge.gearshape") }
                .tag(SettingsViewModel.Tab.variableSets)
        }
        .frame(width: 640, height: 480)
    }
}

// MARK: - View Model

class SettingsViewModel: ObservableObject {
    @Published var tab: Tab = .variableSets
    
    enum Tab {
        case variableSets
    }
}

// MARK: - Preview

struct SettingsView_Preview: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
