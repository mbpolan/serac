//
//  SessionView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Combine
import SwiftUI

// MARK: - View

struct SessionView: View {
    @ActiveVariableSet private var variables: VariableSet?
    @EnvironmentObject private var appState: AppState
    @StateObject private var viewModel: SessionViewModel = SessionViewModel()
    @ObservedObject var session: Session
    
    var body: some View {
        VStack {
            OperationView(request: session.request,
                          disableSend: $viewModel.loading,
                          onSend: handleSend)
            
            HSplitView {
                RequestView(request: session.request)
                    .padding(.trailing, 2)
                
                ActivityView(loading: $viewModel.loading,
                             onAbort: handleStopRequest) {
                    
                    if let error = viewModel.error {
                        ResponseErrorView(message: error)
                    } else {
                        ResponseView(response: session.response)
                            .padding(.leading, 2)
                    }
                }
            }
        }
        .onSendRequest {
            handleSend(session.request)
        }
    }
    
    private func handleStopRequest() {
        if let task = viewModel.task {
            task.cancel()
        }
        
        viewModel.loading = false
    }
    
    private func handleSend(_ request: Request) {
        viewModel.loading = true
        viewModel.error = nil
        
        viewModel.task = HTTPClient.shared.send(request, variables: variables)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                viewModel.loading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    switch error {
                    case NetworkError.authRequestFailed(let response):
                        session.response = Response(from: response)
                    case NetworkError.authRequestError(let message),
                        NetworkError.requestFailed(let message):
                        viewModel.error = message
                    case NetworkError.invalidURL(let url):
                        viewModel.error = "Invalid URL: \(url)"
                    default:
                        viewModel.error = "An unknown error has occurred"
                    }
                }
            }, receiveValue: { response in
                session.response = Response(from: response)
            })
    }
}

// MARK: - View Model

class SessionViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var error: String?
    @Published var task: AnyCancellable?
}

// MARK: - Preview

struct SessionView_Preview: PreviewProvider {
    @State static var session: Session = Session()
    
    static var previews: some View {
        SessionView(session: session)
    }
}
