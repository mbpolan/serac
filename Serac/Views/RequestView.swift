//
//  RequestView.swift
//  Serac
//
//  Created by Mike Polan on 10/23/21.
//

import SwiftUI

// MARK: - View

struct RequestView: View {
    @StateObject var request: Request
    @StateObject private var viewModel: RequestViewModel = RequestViewModel()
    
    var body: some View {
        VStack {
            TabView(selection: $viewModel.tab) {
                RequestBodyView(request: request)
                    .tabItem { Text("Body") }
                    .tag(RequestViewModel.Tab.body)
                
                QueryParameterView(request: request)
                    .tabItem { Text("Query") }
                    .tag(RequestViewModel.Tab.query)
            }
        }
    }
}

// MARK: - View Model

class RequestViewModel: ObservableObject {
    @Published var tab: Tab = .body
    
    enum Tab: Hashable {
        case body
        case query
    }
}

// MARK: - Preview

struct RequestView_Previews: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        RequestView(request: request)
    }
}
