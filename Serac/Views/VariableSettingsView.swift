//
//  VariableSettingsView.swift
//  Serac
//
//  Created by Mike Polan on 11/16/21.
//

import SwiftUI

// MARK: - View

struct VariableSettingsView: View {
    @AppStorage("variableSets") private var variableSets: [VariableSet] = []
    @StateObject private var viewModel: VariableSettingsViewModel = VariableSettingsViewModel()
    
    var body: some View {
        HStack {
            VStack {
                List(variableSets.indices, id: \.self, selection: $viewModel.selected) { index in
                    Text(variableSets[index].name)
                }
                
                Divider()
                
                HStack {
                    Button(action: handleAdd) {
                        Image(systemName: "plus")
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .help("Add a new variable set")
                    
                    Button(action: handleRemove) {
                        Image(systemName: "minus")
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .disabled(viewModel.selected == nil)
                    .help("Remove the selected variable set")
                    
                    Spacer()
                }
                .padding(.leading, 10)
                .padding(.bottom, 5)
            }
            .frame(minWidth: 150)
            .layoutPriority(1)
            
            Divider()
            
            VStack {
                if viewModel.selected == nil {
                    Text("Select or create a variable set")
                        .foregroundColor(.secondary)
                        .centered(.both)
                } else {
                    ScrollView {
                        KeyValueTableView(data: currentVariableSet,
                                          labels: ["Variable", "Value"],
                                          editable: true,
                                          persistAppState: false,
                                          onChange: handleChange)
                    }
                }
            }
            .layoutPriority(3)
        }
    }
    
    private var currentVariableSet: Binding<[KeyValuePair]> {
        return Binding<[KeyValuePair]>(
            get: {
                guard let selected = viewModel.selected else {
                    return []
                }
                
                return variableSets[selected].variables
            },
            set: {
                guard let selected = viewModel.selected else {
                    return
                }
                
                variableSets[selected].variables = $0
                variableSets[selected].objectWillChange.send()
                
                viewModel.objectWillChange.send()
            }
        )
    }
    
    private func handleAdd() {
        variableSets.append(VariableSet(name: "Untitled"))
    }
    
    private func handleRemove() {
        guard let selected = viewModel.selected else { return }
        
        variableSets.remove(at: selected)
    }
    
    private func handleChange() {
        let vs = variableSets
        self.variableSets = vs
    }
}

// MARK: - View Model

class VariableSettingsViewModel: ObservableObject {
    @Published var selected: Int?
    @Published var variableSets: [VariableSet] = []
}

// MARK: - Preview

struct VariableSettingsView_Preview: PreviewProvider {
    static var previews: some View {
        VariableSettingsView()
    }
}
