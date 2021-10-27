//
//  ResponseView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct ResponseView: View {
    @StateObject var response: Response
    @StateObject private var viewModel: ResponseViewModel = ResponseViewModel()
    
    var body: some View {
        VStack {
            if response.valid {
                TabView(selection: $viewModel.tab) {
                    ResponseBodyView(response: response)
                        .tabItem { Text("Body") }
                        .tag(ResponseViewModel.Tab.body)
                    
                    HeadersView(editable: false,
                                message: response)
                        .tabItem { Text("Headers") }
                        .tag(ResponseViewModel.Tab.headers)
                }
            } else {
                Text("Nothing to see here")
                    .foregroundColor(.secondary)
                    .centered(.both)
                    .padding(15)
            }
        }
    }
}

class ResponseViewModel: ObservableObject {
    @Published var tab: Tab = .body
    
    enum Tab {
        case body
        case headers
    }
}

// MARK: - Preview

struct ResponseView_Preview: PreviewProvider {
    @State static var response: Response = Response()
    
    static var previews: some View {
        ResponseView(response: response)
    }
}
