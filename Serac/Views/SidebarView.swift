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
        if let index = appState.collections.firstIndex(where: { $0.id == item.id }) {
            appState.collections.remove(at: index)
        } else if let parent = appState.collections.first(where: { isParentItem(of: item, from: $0 ) }),
                  let index = parent.children?.firstIndex(where: { $0.id == item.id }) {
            
            parent.children?.remove(at: index)
            parent.objectWillChange.send()
            appState.objectWillChange.send()
        } else {
            print("WARN: could not find parent of item \(item.id)")
        }
    }
    
    private func isParentItem(of item: CollectionItem, from node: CollectionItem) -> Bool {
        return node.children?.contains {
            if $0.id == item.id {
                return true
            }
            
            if $0.type == .group {
                return isParentItem(of: item, from: $0)
            }
            
            return false
        } ?? false
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
    
    var body: some View {
        if item.type == .group {
            HStack {
                Image(systemName: "folder")
                Text(item.groupName ?? "")
            }
            .contextMenu {
                Button("Add Group", action: { onAddGroup(item) })
                Button("Add Request", action: { onAddRequest(item) })
                Button("Remove", action: { onRemove(item) })
            }
        } else if let request = item.request {
            HStack {
                Text(request.method.rawValue)
                    .bold()
                
                Spacer()
                
                Text(request.name)
            }
            .contextMenu {
                Button("Remove", action: { onRemove(item) })
            }
        }
    }
}

// MARK: - Preview

struct SidebarView_Preview: PreviewProvider {
    static var previews: some View {
        SidebarView()
            .environmentObject(AppState())
    }
}
