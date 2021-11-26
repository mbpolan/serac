//
//  QuickFindView.swift
//  Serac
//
//  Created by Mike Polan on 11/24/21.
//

import SwiftUI

// MARK: - View

struct QuickFindView: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: QuickFindViewModel = QuickFindViewModel()
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            QuickFindTextField("Search for items",
                               text: $viewModel.query,
                               onAction: handleAction)
            
            Divider()
            
            if viewModel.query.isEmpty {
                Text("Search for requests")
                    .foregroundColor(.secondary)
                    .padding(5)
                    .centered(.horizontal)
            } else if viewModel.matches.isEmpty {
                Text("No items found")
                    .foregroundColor(.secondary)
                    .padding(5)
                    .centered(.horizontal)
            }
            
            ForEach(0..<maximumResults, id: \.self) { i in
                HStack {
                    Text((i < viewModel.matches.count ? viewModel.matches[i].request?.name : "" as String?) ?? "")
                        .padding(.leading, 5)
                        .font(.system(size: NSFont.systemFontSize + 4))
                    
                    Spacer()
                }
                .padding([.top, .bottom], 1)
                .background(i == viewModel.selection ? Color.accentColor : Color.clear)
                .cornerRadius(5)
            }
        }
        .onReceive(viewModel.$query, perform: updateSearch)
        .padding([.top, .bottom], 10)
        .padding([.leading, .trailing], 5)
        .frame(width: 400)
    }
    
    private func handleAction(_ action: QuickFindTextField.Action) {
        switch action {
            // move selection to next or previous item
        case .previousSelection, .nextSelection:
            let delta = action == .previousSelection ? -1 : 1
            handleMoveSelection(delta: delta)
            
            // close the quick find view
        case .exit:
            onDismiss()
            
            // open the selected item
        case .commit:
            handleActivateSelection()
        }
    }
    
    private func handleMoveSelection(delta: Int) {
        var selection = viewModel.selection + delta
        if selection < 0 {
            selection = viewModel.matches.count - 1
        } else if selection >= viewModel.matches.count {
            selection = 0
        }
        
        viewModel.selection = selection
    }
    
    private func handleActivateSelection() {
        guard viewModel.selection >= 0 && viewModel.selection < viewModel.matches.count else {
            return
        }
        
        let item = viewModel.matches[viewModel.selection]
        OpenCollectionItemNotification(item: item).notify()
        
        onDismiss()
    }
    
    private func updateSearch(_ query: String) {
        // search for matching requests by name
        viewModel.matches = []
        appState.collections.forEach { item in
            matchCollectionItem(item, query: query, into: &viewModel.matches)
        }
        
        // update the selection based on several conditions:
        // 1. no matches are found; hide the selection
        // 2. we have less matches now than before; set the selection to the first entry
        // 3. selection was not set but we have at least one match; set the selection to the first entry
        if viewModel.matches.isEmpty {
            viewModel.selection = -1
        } else if viewModel.selection >= viewModel.matches.count {
            viewModel.selection = 0
        } else if viewModel.selection == -1 {
            viewModel.selection = 0
        }
    }
    
    private func matchCollectionItem(_ item: CollectionItem, query: String, into result: inout [CollectionItem]) {
        switch item.type {
        case .request:
            if let _ = item.request?.name.range(of: query, options: .caseInsensitive) {
                result.append(item)
            }
            
        case .group, .root:
            item.children?.forEach {
                matchCollectionItem($0, query: query, into: &result)
            }
        }
    }
}

// MARK: - Extensions

extension QuickFindView {
    var maximumResults: Int { 5 }
}

// MARK: - View Model

class QuickFindViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var matches: [CollectionItem] = []
    @Published var selection: Int = -1
}

// MARK: - Text Field

struct QuickFindTextField: NSViewRepresentable {
    let title: String
    @Binding var text: String
    let onAction: (_ action: Action) -> Void
    
    init(_ title: String,
         text: Binding<String>,
         onAction: @escaping(_ action: Action) -> Void) {
        
        self.title = title
        self._text = text
        self.onAction = onAction
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.stringValue = text
        field.isBezeled = false
        field.focusRingType = .none
        field.backgroundColor = .clear
        field.font = .systemFont(ofSize: NSFont.systemFontSize + 4)
        field.delegate = context.coordinator
        
        return field
    }
    
    func updateNSView(_ nsView: NSTextField, context: Context) {
        if text != nsView.stringValue {
            nsView.stringValue = text
        }
    }
}

// MARK: - Extensions & Text Field Coordinator

extension QuickFindTextField {
    enum Action {
        case previousSelection
        case nextSelection
        case exit
        case commit
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate, NSControlTextEditingDelegate {
        let parent: QuickFindTextField
        
        init(_ parent: QuickFindTextField) {
            self.parent = parent
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            
            self.parent.text = field.stringValue
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            
            self.parent.text = field.stringValue
            self.parent.onAction(.commit)
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            
            self.parent.text = field.stringValue
        }
        
        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSStandardKeyBindingResponding.moveUp(_:)) {
                parent.onAction(.previousSelection)
                return true
            } else if commandSelector == #selector(NSStandardKeyBindingResponding.moveDown(_:)) {
                parent.onAction(.nextSelection)
                return true
            } else if commandSelector == #selector(NSSavePanel.cancel(_:)) {
                parent.onAction(.exit)
                return true
            } else {
                return false
            }
        }
    }
}

// MARK: - Preview

struct QuickFindView_Preview: PreviewProvider {
    static var previews: some View {
        QuickFindView(onDismiss: {})
            .environmentObject(AppState())
    }
}
