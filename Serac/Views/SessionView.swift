//
//  SessionView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct SessionView: View {
    @StateObject var session: Session
    
    var body: some View {
        VStack {
            OperationView(request: session.request,
                          onSend: handleSend)
            
            HSplitView {
                RequestView(request: session.request)
                
                ResponseView(response: session.response)
            }
            
            Spacer()
        }
        .onSendRequest {
            handleSend(session.request)
        }
    }
    
    private func handleSend(_ request: Request) {
        HTTPClient.shared.send(request) { result in
            switch result {
            case .success(let response):
                DispatchQueue.main.async {
                    session.response.valid = true
                    session.response.statusCode = response.statusCode
                    session.response.contentLength = response.contentLength
                    session.response.contentType = response.contentType
                    session.response.headers = response.headers
                    session.response.data = response.data
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

// MARK: - Preview

struct SessionView_Preview: PreviewProvider {
    @State static var session: Session = Session()
    
    static var previews: some View {
        SessionView(session: session)
    }
}
