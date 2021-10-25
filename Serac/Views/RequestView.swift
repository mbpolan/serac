//
//  RequestView.swift
//  Serac
//
//  Created by Mike Polan on 10/23/21.
//

import SwiftUI

// MARK: - View

struct RequestView: View {
    @Binding var request: Request
    @StateObject private var viewModel: RequestViewModel = RequestViewModel()
    
    var body: some View {
        VStack {
            TabView(selection: $viewModel.tab) {
                RequestBodyView()
                    .tabItem { Text("Body") }
                    .tag(RequestViewModel.Tab.body)
            }
        }
    }
}

class RequestViewModel: ObservableObject {
    @Published var tab: Tab = .body
    
    enum Tab: Hashable {
        case body
    }
}

// MARK: - Preview

struct RequestView_Previews: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        RequestView(request: $request)
    }
}
