//
//  HeadersView.swift
//  Serac
//
//  Created by Mike Polan on 10/25/21.
//

import SwiftUI

// MARK: - View

struct HeadersView: View {
    let editable: Bool
    @ObservedObject var message: HTTPMessage
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                Section {
                    Text("Header")
                    Text("Value")
                    
                    if editable {
                        Button(action: handleAdd) {
                            Image(systemName: "plus")
                        }
                        .clipShape(Rectangle())
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 32, height: 32)
                    }
                }
                
                ForEach(message.headers.indices, id: \.self) { index in
                    TextField("",
                              text: $message.headers[index].key)
                        .disabled(!editable)
                    TextField("",
                              text: $message.headers[index].value)
                        .disabled(!editable)
                    
                    if editable {
                        Button(action: { handleRemove(index) }) {
                            Image(systemName: "minus")
                        }
                        .clipShape(Rectangle())
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 32, height: 32)
                    }
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
        message.headers.append(KeyValuePair("", ""))
    }
    
    private func handleRemove(_ index: Int) {
        DispatchQueue.main.async {
            message.headers.remove(at: index)
        }
    }
}

// MARK: - Preview

struct HeadersView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        request.headers = []
        return HeadersView(editable: true, message: request)
    }
}

