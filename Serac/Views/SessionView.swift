//
//  SessionView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct SessionView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject var session: Session
    @StateObject private var viewModel: SessionViewModel = SessionViewModel()
    
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
                    
                    ResponseView(response: session.response)
                        .padding(.leading, 2)
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
        
        viewModel.task = HTTPClient.shared.send(request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    session.response = Response(
                        statusCode: response.statusCode,
                        contentLength: response.contentLength,
                        contentType: response.contentType,
                        headers: response.headers,
                        data: response.data,
                        startTime: response.startTime,
                        endTime: response.endTime)
                case .failure(let error):
                    print(error.localizedDescription)
                }
                
                viewModel.loading = false
            }
        }
    }
}

// MARK: - View Model

class SessionViewModel: ObservableObject {
    @Published var loading: Bool = false
    @Published var task: URLSessionDataTask?
}

// MARK: - Preview

struct SessionView_Preview: PreviewProvider {
    @State static var session: Session = Session()
    
    static var previews: some View {
        SessionView(session: session)
    }
}
