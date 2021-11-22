//
//  QueryParameterView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct QueryParameterView: View {
    @AppStorage("activeVariableSet") private var activeVariableSet: String?
    @AppStorage("variableSets") private var variableSets: [VariableSet] = []
    @StateObject var request: Request
    @StateObject private var viewModel: QueryParameterViewModel = QueryParameterViewModel()
    
    var body: some View {
        ScrollView {
            KeyValueTableView(data: $viewModel.parameters,
                              labels: ["Parameter", "Value"],
                              editable: true,
                              formatter: formatter,
                              persistAppState: false,
                              onChange: handleUpdateUrl)
                .padding([.leading, .trailing], 10)
        }
        .onReceive(request.$url) { url in
            updateModel(from: url)
        }
        .onAppear {
            updateModel(from: request.url)
        }
        .onChange(of: viewModel.parameters) { params in
            handleUpdateUrl()
        }
    }
    
    private var variables: VariableSet? {
        variableSets.first(where: { $0.id == activeVariableSet ?? "" })
    }
    
    private var formatter: TextFormatter {
        TextFormatter(adaptors: [
            VariableFormatAdaptor(variables: variables)
        ])
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
            PersistAppStateNotification().notify()
        }
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
