//
//  QuickFindView.swift
//  Serac
//
//  Created by Mike Polan on 11/24/21.
//

import SwiftUI

// MARK: - View

struct CommandPaletteView: View {
    @AppStorage("variableSets") private var variableSets: [VariableSet] = []
    @ActiveVariableSet private var variables: VariableSet?
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: CommandPaletteViewModel = CommandPaletteViewModel()
    let initialMode: InitialMode
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.title2)
                
                CommandPaletteTextField("Search for requests or actions",
                                        text: $viewModel.query,
                                        onAction: handleAction)
            }
            .padding(5)
            
            Divider()
            
            if !viewModel.query.isEmpty && viewModel.actions.isEmpty {
                Text("No items found")
                    .foregroundColor(.secondary)
                    .padding(5)
                    .centered(.horizontal)
            }
            
            ScrollView {
                ForEach(0..<viewModel.actions.count, id: \.self) { i in
                    HStack {
                        makeItemText(at: i)
                            .padding(.leading, 5)
                        
                        Spacer()
                    }
                    .padding([.top, .bottom], 1)
                    .background(i == viewModel.selection ? Color.accentColor : Color.clear)
                    .cornerRadius(5)
                }
            }
            
            Spacer()
        }
        .onAppear {
            viewModel.query = initialMode == .search ? "" : ">"
        }
        .onReceive(viewModel.$query, perform: updateSearch)
        .padding([.top, .bottom], 10)
        .padding([.leading, .trailing], 5)
        .frame(minWidth: 400, idealWidth: nil, maxWidth: .infinity, minHeight: 400, idealHeight: nil, maxHeight: 400)
    }
    
    @ViewBuilder
    private func makeItemText(at index: Int) -> some View {
        let item = viewModel.actions[index]
        
        switch item {
        case .collectionItem(let item, let path, _):
            HStack {
                Text(path.joined(separator: " > "))
                    .foregroundColor(Color(NSColor.secondaryLabelColor))
                    .font(.system(size: NSFont.systemFontSize))
                    .lineLimit(1)
                
                Spacer()
                
                Text(item.request?.name ?? "Untitled")
                    .font(.system(size: NSFont.systemFontSize + 4))
            }
            
        case .command(let item, _):
            HStack {
                Text(item.name)
                    .font(.system(size: NSFont.systemFontSize + 4))
                
                Spacer()
                
                Text(item.description).foregroundColor(.secondary)
                    .font(.system(size: NSFont.systemFontSize))
            }
            
        case .argument(_, let label, _, _):
            HStack {
                Text(label)
                    .font(.system(size: NSFont.systemFontSize + 4))
            }
        }
    }
    
    private func handleAction(_ action: CommandPaletteTextField.Action) {
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
            selection = viewModel.actions.count - 1
        } else if selection >= viewModel.actions.count {
            selection = 0
        }
        
        viewModel.selection = selection
    }
    
    private func handleActivateSelection() {
        guard viewModel.selection >= 0 && viewModel.selection < viewModel.actions.count else {
            return
        }
        
        let item = viewModel.actions[viewModel.selection]
        switch item {
        case .collectionItem(let item, _, _):
            OpenCollectionItemNotification(item: item).notify()
            onDismiss()
            
        case .command(let item, _):
            if item.requiresArgument {
                resetSearchState(mode: .argument(item))
            } else {
                activateCommand(item)
                onDismiss()
            }
            
        case.argument(let item, _, let value, _):
            activateCommand(item, argument: value)
            break
        }
    }
    
    private func resetSearchState(mode: CommandPaletteViewModel.ViewMode) {
        viewModel.mode = mode
        viewModel.actions = []
        viewModel.query = ""
    }
    
    private func activateCommand(_ item: CommandPaletteViewModel.CommandItem, argument value: Any? = nil) {
        switch item {
        case .changeVariableSet:
            ChangeVariableSetNotification(id: (value as? VariableSet)?.id).notify()
            break
        }
        
        onDismiss()
    }
    
    private func updateSearch(_ query: String) {
        switch viewModel.mode {
        case .free:
            if query.starts(with: ">") {
                searchForCommands(query: String(query.dropFirst()))
            } else {
                searchForRequests(query: query)
            }
            
        case .argument(let item):
            updateSearchForCommand(query: query, item: item)
        }
        
        // update the selection based on several conditions:
        // 1. no matches are found; hide the selection
        // 2. we have less matches now than before; set the selection to the first entry
        // 3. selection was not set but we have at least one match; set the selection to the first entry
        if viewModel.actions.isEmpty {
            viewModel.selection = -1
        } else if viewModel.selection >= viewModel.actions.count {
            viewModel.selection = 0
        } else if viewModel.selection == -1 {
            viewModel.selection = 0
        }
    }
    
    private func updateSearchForCommand(query: String, item: CommandPaletteViewModel.CommandItem) {
        switch item {
            // show available variable sets
        case .changeVariableSet:
            viewModel.actions = [.argument(item, "None", nil, .exact)]
            
            if query.isEmpty {
                viewModel.actions.append(contentsOf: variableSets.map { .argument(item, $0.name, $0, .exact) })
            } else {
                viewModel.actions.append(contentsOf: variableSets.filter {
                    $0.name.contains(caseInsensitive: query)
                }.map { .argument(item, $0.name, $0, .exact) })
            }
        }
    }
    
    private func searchForRequests(query: String) {
        // search for matching requests by name
        viewModel.actions = []
        
        appState.collections.forEach { item in
            matchCollectionItem(item, path: [], query: query, into: &viewModel.actions)
        }
        
        // sort the results based on best match
        viewModel.actions.sort(by: { a, b in
            return a.rating.rawValue > b.rating.rawValue
        })
    }
    
    private func searchForCommands(query: String) {
        // was an argument given as part of the search?
        let statement = query.split(separator: " ")
        
        // match on an exact command
        if query.hasSuffix(" ") || statement.count > 1 {
            let commandName = statement[0]
            
            // switch to searching on arguments if we matched a command
            if let command = CommandPaletteViewModel.CommandItem.allCases.first(where: { $0.name == commandName }) {
                updateSearchForCommand(query: Array(statement[1...]).joined(separator: " "), item: command)
            }
        } else if query.isEmpty {
            // show all available commands
            viewModel.actions = CommandPaletteViewModel.CommandItem.allCases.map { .command($0, .exact) }
        } else {
            // filter by matching commands
            viewModel.actions = CommandPaletteViewModel.CommandItem.allCases.filter { item in
                return item.name.contains(caseInsensitive: query)
            }.map { .command($0, .exact) }
        }
    }
    
    private func matchCollectionItem(_ item: CollectionItem, path: [String], query: String, into result: inout [CommandPaletteViewModel.ActionItem]) {
        switch item.type {
        case .request:
            guard let request = item.request else { return }
            
            // determine how close of a match this request is, if any
            // look for exact matches in the request name, partial matches in the request name, or
            // a match in one of the request's group names
            if request.name.caseInsensitiveCompare(query) == .orderedSame {
                result.append(.collectionItem(item, path, .exact))
            } else if request.name.contains(caseInsensitive: query) {
                result.append(.collectionItem(item, path, .partial))
            } else if path.contains(where: { $0.contains(caseInsensitive: query) }) {
                result.append(.collectionItem(item, path, .contextual))
            }
            
        case .group, .root:
            var thisPath = path
            if let groupName = item.groupName {
                thisPath.append(groupName)
            }
            
            item.children?.forEach {
                matchCollectionItem($0, path: thisPath, query: query, into: &result)
            }
        }
    }
}

// MARK: - Extensions

extension CommandPaletteView {
    var maximumResults: Int { 50 }
    
    enum InitialMode: Identifiable {
        case search
        case command
        
        var id: Int {
            hashValue
        }
    }
}

// MARK: - View Model

class CommandPaletteViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var actions: [ActionItem] = []
    @Published var selection: Int = -1
    @Published var mode: ViewMode = .free
    
    enum ViewMode {
        case free
        case argument(_ item: CommandItem)
    }
    
    enum CommandItem: CaseIterable {
        case changeVariableSet
        
        var name: String {
            switch self {
            case .changeVariableSet:
                return "setv"
            }
        }
        
        var description: String {
            switch self {
            case .changeVariableSet:
                return "Use the selected variable set"
            }
        }
        
        var requiresArgument: Bool {
            switch self {
            case .changeVariableSet:
                return true
            }
        }
    }
    
    enum MatchRating: Int {
        case exact = 3
        case partial = 2
        case contextual = 1
    }
    
    enum ActionItem {
        case collectionItem(_ item: CollectionItem, _ path: [String], _ rating: MatchRating)
        case command(_ item: CommandItem, _ rating: MatchRating)
        case argument(_ item: CommandItem, _ label: String, _ value: Any?, _ rating: MatchRating)
        
        var rating: MatchRating {
            switch self {
            case .collectionItem(_, _, let rating):
                return rating
            case .command(_, let rating):
                return rating
            case .argument(_, _, _, let rating):
                return rating
            }
        }
    }
}

// MARK: - Text Field

struct CommandPaletteTextField: NSViewRepresentable {
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
        field.placeholderString = title
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

extension CommandPaletteTextField {
    enum Action {
        case previousSelection
        case nextSelection
        case exit
        case commit
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate, NSControlTextEditingDelegate {
        let parent: CommandPaletteTextField
        
        init(_ parent: CommandPaletteTextField) {
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

struct CommandPalette_Preview: PreviewProvider {
    static var previews: some View {
        CommandPaletteView(initialMode: .search, onDismiss: {})
            .environmentObject(AppState())
    }
}
