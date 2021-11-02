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
                             onRemove: { handleRemove($0) })
            }
            .contextMenu {
                Button("Add Group", action: { handleAddGroup() })
                Button("Add Request", action: { handleAddRequest() })
            }
        }
    }
    
    private func handleAddGroup(under parent: CollectionItem? = nil) {
        let group = CollectionItem(groupName: "New Group")
        addToCollections(group, under: parent)
    }
    
    private func handleAddRequest(under parent: CollectionItem? = nil) {
        let request = CollectionItem(request: Request())
        addToCollections(request, under: parent)
    }
    
    private func handleRemove(_ item: CollectionItem) {
        guard let (parent, index) = findParentItem(of: item) else {
            print("WARN: cannot find parent of item \(item.id)")
            return
        }
        
        print("Found parent: \(parent.id) of type \(parent.type) at index \(index)")
        if parent.type == .root {
            appState.collections.remove(at: index)
        } else {
            parent.children?.remove(at: index)
        }
        
        appState.objectWillChange.send()
    }
    
    private func findParentItem(of item: CollectionItem) -> (CollectionItem, Int)? {
        let root = CollectionItem()
        root.children = appState.collections
        
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
    }
}

// MARK: - ListItemView

fileprivate struct ListItemView: View {
    @ObservedObject var item: CollectionItem
    let onAddGroup: (_ parent: CollectionItem?) -> Void
    let onAddRequest: (_ parent: CollectionItem?) -> Void
    let onRemove: (_ item: CollectionItem) -> Void
    
    @State private var editing: Bool = false
    @State private var editedText: String = ""
    
    var body: some View {
        if item.type == .group {
            HStack {
                Image(systemName: "folder")
                
                if editing {
                    TextField("", text: $editedText, onCommit: handleFinishRename)
                } else {
                    Text(item.groupName ?? "")
                }
            }
            .contextMenu {
                Button("Add Group", action: { onAddGroup(item) })
                Button("Add Request", action: { onAddRequest(item) })
                Button("Rename", action: { handleStartRename() })
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
    }
}

// MARK: - Preview

struct SidebarView_Preview: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environmentObject(AppState())
    }
}
