//
//  QueryParameterView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct QueryParameterView: View {
    @StateObject var request: Request
    @StateObject private var viewModel: QueryParameterViewModel = QueryParameterViewModel()
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                .init(.flexible()),
                .init(.flexible()),
                .init(.fixed(40))]) {
                    
                    Section {
                        Text("Parameter")
                        Text("Value")
                        Button(action: handleAdd) {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 32, height: 32)
                    }
                    
                    ForEach(viewModel.parameters.indices, id: \.self) { index in
                        TextField("",
                                  text: $viewModel.parameters[index].key,
                                  onCommit: handleUpdateUrl)
                        TextField("",
                                  text: $viewModel.parameters[index].value,
                                  onCommit: handleUpdateUrl)
                        
                        Button(action: { handleRemove(index) }) {
                            Image(systemName: "minus")
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .frame(width: 32, height: 32)
                    }
                }
        }
        .onReceive(request.$url) { url in
            updateModel(from: url)
        }
        .onAppear {
            updateModel(from: request.url)
        }
    }
    
    private func updateModel(from url: String) {
        let items = (URLComponents(string: url)?.queryItems ?? []).map { item in
            KeyValuePair(item.name, item.value ?? "")
        }
        
        // have the query parameters changed compared to what we have in the model?
        let changed = items.count != viewModel.parameters.count || items.indices.first { index in
            return items[index] != viewModel.parameters[index]
        } != nil
        
        if changed {
            viewModel.parameters = items
        }
    }
    
    private func handleUpdateUrl() {
        guard var components = URLComponents(string: request.url) else {
            return
        }
        
        components.queryItems = viewModel.parameters.map { param in
            URLQueryItem(name: param.key, value: param.value)
        }
        
        if let url = components.string {
            request.url = url
        }
    }
    
    private func handleAdd() {
        viewModel.parameters.append(KeyValuePair("", ""))
    }
    
    private func handleRemove(_ index: Int) {
        viewModel.parameters.remove(at: index)
    }
}

// MARK: - View Model

class QueryParameterViewModel: ObservableObject {
    @Published var url: String = ""
    @Published var parameters: [KeyValuePair] = []
}

// MARK: - Preview

struct QueryParameterView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        request.url = "https://google.com?key=value"
        return QueryParameterView(request: request)
    }
}
