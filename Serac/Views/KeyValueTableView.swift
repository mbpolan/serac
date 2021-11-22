//
//  KeyValueTableView.swift
//  Serac
//
//  Created by Mike Polan on 11/14/21.
//

import SwiftUI

// MARK: - View

struct KeyValueTableView: View {
    @Binding var data: [KeyValuePair]
    let labels: [String]
    let editable: Bool
    var formatter: TextFormatter? = nil
    var persistAppState: Bool = true
    var onChange: () -> Void = {}
    
    var body: some View {
        LazyVGrid(columns: columns) {
            Section {
                ForEach(labels, id: \.self) { label in
                    Text(label)
                }
                
                if editable {
                    Button(action: handleAdd) {
                        Image(systemName: "plus")
                            .padding(8)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
            
            ForEach(data.indices, id: \.self) { index in
                AppTextField(text: $data[index].key,
                             formatter: formatter,
                             onCommit: handleCommit)
                    .disabled(!editable)
                
                AppTextField(text: $data[index].value,
                             formatter: formatter,
                             onCommit: handleCommit)
                    .disabled(!editable)
                
                if editable {
                    Button(action: { handleRemove(index) }) {
                        Image(systemName: "minus")
                            .padding(8)
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
            }
        }
    }
    
    private var columns: [GridItem] {
        var columns: [GridItem] = [
            .init(.flexible()),
            .init(.flexible()),
        ]
        
        if editable {
            columns.append(.init(.fixed(40)))
        }
        
        return columns
    }
    
    private func handleAdd() {
        data.append(KeyValuePair("", ""))
        
        if persistAppState {
            PersistAppStateNotification().notify()
        }
    }
    
    private func handleRemove(_ index: Int) {
        DispatchQueue.main.async {
            data.remove(at: index)
            
            if persistAppState {
                PersistAppStateNotification().notify()
            }
        }
    }
    
    private func handleCommit() {
        onChange()
    }
}

// MARK: - Preview

struct KeyValueTableView_Preview: PreviewProvider {
    @State static var empty: [KeyValuePair] = []
    @State static var data: [KeyValuePair] = [
        KeyValuePair("abc", "def")
    ]
    
    static var previews: some View {
        KeyValueTableView(
            data: $empty,
            labels: ["Key", "Value"],
            editable: true)
            .previewDisplayName("Empty")
            .frame(width: 300, height: 250)
        
        KeyValueTableView(
            data: $data,
            labels: ["Key", "Value"],
            editable: true)
            .previewDisplayName("Non-Empty")
            .frame(width: 300, height: 250)
    }
}
