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
                List(viewModel.variableSets.indices, id: \.self, selection: $viewModel.selected) { index in
                    if viewModel.edited == index {
                        AppTextField(text: $viewModel.variableSets[index].name,
                                     introspect: handleFocusTextField,
                                     onCommit: handleFinishEditing)
                    } else {
                        Text(viewModel.variableSets[index].name)
                            .contextMenu {
                                Button("Rename") { handleRename(index) }
                            }
                    }
                }
                
                Divider()
                
                HStack {
                    Button(action: handleAdd) {
                        Image(systemName: "plus")
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Add a new variable set")
                    
                    Button(action: handleRemove) {
                        Image(systemName: "minus")
                            .frame(width: 16, height: 16)
                    }
                    .buttonStyle(BorderlessButtonStyle())
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
                if let selected = viewModel.selected {
                    ScrollView {
                        KeyValueTableView(data: $viewModel.variableSets[selected].variables,
                                          labels: ["Variable", "Value"],
                                          editable: true,
                                          persistAppState: false,
                                          onChange: handleChange)
                    }
                } else {
                    Text("Select or create a variable set")
                        .foregroundColor(.secondary)
                        .centered(.both)
                }
            }
            .layoutPriority(3)
        }
        .onAppear {
            viewModel.variableSets = variableSets
        }
        .onDisappear(perform: updateAppStorage)
    }
    
    private func updateAppStorage() {
        variableSets = viewModel.variableSets
    }
    
    private func handleAdd() {
        viewModel.variableSets.append(VariableSet(name: "Untitled"))
        updateAppStorage()
    }
    
    private func handleRemove() {
        guard let selected = viewModel.selected else { return }
        
        viewModel.selected = nil
        viewModel.variableSets.remove(at: selected)
        updateAppStorage()
    }
    
    private func handleRename(_ index: Int) {
        viewModel.edited = index
    }
    
    private func handleFocusTextField(_ nsTextField: NSTextField) {
        // kinda ugly but we need to delay updating the first responder until the system
        // has finished drawing the text field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            nsTextField.becomeFirstResponder()
        }
    }
    
    private func handleFinishEditing() {
        viewModel.edited = nil
        updateAppStorage()
    }
    
    private func handleChange() {
        updateAppStorage()
    }
}

// MARK: - View Model

class VariableSettingsViewModel: ObservableObject {
    @Published var selected: Int?
    @Published var edited: Int?
    @Published var variableSets: [VariableSet] = []
}

// MARK: - Preview

struct VariableSettingsView_Preview: PreviewProvider {
    static var previews: some View {
        VariableSettingsView()
    }
}
