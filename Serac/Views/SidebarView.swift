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
    @State private var selected: String?
    
    var body: some View {
        VStack {
            List(appState.collections, id: \.id, children: \.children, selection: $selected) { item in
                ListItemView(item: item,
                             onAddGroup: { handleAddGroup(under: $0) },
                             onAddRequest: { handleAddRequest(under: $0) },
                             onRemove: { handleRemove($0) },
                             onDuplicate: { handleDuplicate($0) })
            }
            .contextMenu {
                Button("Add Group", action: { handleAddGroup() })
                Button("Add Request", action: { handleAddRequest() })
            }
            
            Divider()
        }
        .onChange(of: selected) { item in
            handleOpen(item)
        }
    }
    
    private func handleOpen(_ id: String?) {
        guard let id = id,
              let item = findItem(by: id),
              item.type == .request else {
                  print("WARN: could not find item \(id ?? "nil")")
                  return
              }
        
        if let existingSession = appState.sessions.first(where: { $0.id == id }) {
            // TODO: save current session if any
            appState.activeSession = existingSession
        } else {
            appState.activeSession = Session(id: id, request: item.request ?? Request())
        }
    }
    
    private func handleAddGroup(under parent: CollectionItem? = nil) {
        let group = CollectionItem(groupName: "New Group")
        addToCollections(group, under: parent)
        
        PersistAppStateNotification().notify()
    }
    
    private func handleAddRequest(under parent: CollectionItem? = nil) {
        let request = CollectionItem(request: Request())
        addToCollections(request, under: parent)
        
        PersistAppStateNotification().notify()
    }
    
    private func handleRemove(_ item: CollectionItem) {
        guard let (parent, index) = findParentItem(of: item) else {
            print("WARN: cannot find parent of item \(item.id)")
            return
        }
        
        if parent.type == .root {
            appState.collections.remove(at: index)
        } else {
            parent.children?.remove(at: index)
        }
        
        appState.objectWillChange.send()
        PersistAppStateNotification().notify()
    }
    
    private func handleDuplicate(_ item: CollectionItem) {
        guard let request = item.request,
              let (parent, index) = findParentItem(of: item),
              parent.type != .request else {
                  return
              }
        
        let dupe = Request()
        dupe.name = "Copy of \(request.name)"
        dupe.method = request.method
        dupe.url = request.url
        dupe.bodyContentType = request.bodyContentType
        dupe.body = request.body
        
        let newItem = CollectionItem(request: dupe)
        
        if parent.type == .root {
            appState.collections.insert(newItem, at: index + 1)
        } else {
            parent.children?.insert(newItem, at: index + 1)
        }
        
        appState.objectWillChange.send()
        PersistAppStateNotification().notify()
    }
    
    private func findItem(by id: String, from node: CollectionItem? = nil) -> CollectionItem? {
        let parent = node ?? CollectionItem(children: appState.collections)
        
        if parent.id == id {
            return parent
        }
        
        for child in parent.children ?? [] {
            if child.id == id {
                return child
            } else if child.type == .group,
                      let found = findItem(by: id, from: child) {
                return found
            }
        }
        
        return nil
    }
    
    private func findParentItem(of item: CollectionItem) -> (CollectionItem, Int)? {
        let root = CollectionItem(children: appState.collections)
        return findParentItem(of: item, from: root)
    }
    
    private func findParentItem(of item: CollectionItem, from node: CollectionItem) -> (CollectionItem, Int)? {
        guard let children = node.children else {
            return nil
        }
        
        for (index, child) in children.enumerated() {
            if child.id == item.id {
                return (node, index)
            }
            
            if child.type == .group,
               let found = findParentItem(of: item, from: child) {
                return found
            }
        }
        
        return nil
    }
    
    private func addToCollections(_ item: CollectionItem, under parent: CollectionItem? = nil) {
        if let parent = parent {
            if parent.children == nil {
                parent.children = []
            }
            
            parent.children?.append(item)
        } else {
            appState.collections.append(item)
        }
        
        appState.objectWillChange.send()
        
        PersistAppStateNotification().notify()
    }
}

// MARK: - ListItemView

fileprivate struct ListItemView: View {
    @ObservedObject var item: CollectionItem
    let onAddGroup: (_ parent: CollectionItem?) -> Void
    let onAddRequest: (_ parent: CollectionItem?) -> Void
    let onRemove: (_ item: CollectionItem) -> Void
    let onDuplicate: (_ item: CollectionItem) -> Void
    
    @State private var editing: Bool = false
    @State private var editedText: String = ""
    
    var body: some View {
        if item.type == .group {
            HStack {
                Image(systemName: "folder")
                    .padding(.leading, 5)
                
                if editing {
                    TextField("", text: $editedText, onCommit: handleFinishRename)
                } else {
                    Text(item.groupName ?? "")
                }
            }
            .contextMenu {
                Button("Add Group", action: { onAddGroup(item) })
                Button("Add Request", action: { onAddRequest(item) })
                Divider()
                Button("Rename", action: { handleStartRename() })
                Divider()
                Button("Remove", action: { onRemove(item) })
            }
        } else if let request = item.request {
            HStack {
                Text(request.method.rawValue)
                    .bold()
                
                Spacer()
                
                if editing {
                    TextField("", text: $editedText, onCommit: handleFinishRename)
                } else {
                    Text(item.request?.name ?? "")
                }
            }
            .contextMenu {
                Button("Rename", action: { handleStartRename() })
                Button("Duplicate", action: { onDuplicate(item) })
                Divider()
                Button("Remove", action: { onRemove(item) })
            }
        }
    }
    
    private func handleStartRename() {
        editing = true
        editedText = (item.type == .group ? item.groupName : item.request?.name) ?? ""
    }
    
    private func handleFinishRename() {
        if item.type == .group {
            item.groupName = editedText
        } else {
            item.request?.name = editedText
        }
        
        editing = false
        editedText = ""
        
        PersistAppStateNotification().notify()
    }
}

// MARK: - Preview

struct SidebarView_Preview: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environmentObject(AppState())
    }
}
