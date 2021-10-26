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
    @StateObject var message: HTTPMessage
    @StateObject private var viewModel: HeadersViewModel = HeadersViewModel()
    
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
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 32, height: 32)
                    }
                }
                
                ForEach(viewModel.headers.indices, id: \.self) { index in
                    TextField("",
                              text: $viewModel.headers[index].key)
                        .disabled(!editable)
                    TextField("",
                              text: $viewModel.headers[index].value)
                        .disabled(!editable)
                    
                    if editable {
                        Button(action: { handleRemove(index) }) {
                            Image(systemName: "minus")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 32, height: 32)
                    }
                }
            }
        }
        .onAppear {
            updateModel(from: message)
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
    
    private func updateModel(from message: HTTPMessage) {
        viewModel.headers = message.headers.map { (k, v) in
            return KeyValuePair(k, v)
        }
    }
    
    private func handleAdd() {
        viewModel.headers.append(KeyValuePair("", ""))
    }
    
    private func handleRemove(_ index: Int) {
        viewModel.headers.remove(at: index)
    }
}

// MARK: - View Model

class HeadersViewModel: ObservableObject {
    @Published var headers: [KeyValuePair] = []
}

// MARK: - Preview

struct HeadersView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        request.headers = [:]
        return HeadersView(editable: true, message: request)
    }
}

