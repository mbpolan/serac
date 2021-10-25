//
//  SessionView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct SessionView: View {
    @Binding var session: Session
    
    var body: some View {
        VStack {
            HStack {
                Picker(selection: $session.request.method, label: Text("")) {
                    ForEach(HTTPMethod.allCases, id: \.self) { verb in
                        Text(verb.rawValue).tag(verb)
                    }
                }
                .frame(minWidth: 80)
                .layoutPriority(2)
                
                TextField("", text: $session.request.url)
                    .layoutPriority(3)
                
                Button("Send", action: handleSend)
                    .layoutPriority(1)
            }
            .padding([.top, .trailing], 5)
            .padding([.bottom], 5)
            
            HSplitView {
                RequestView(request: $session.request)
                
                ResponseView(response: $session.response)
            }
            
            Spacer()
        }
    }
    
    private func handleSend() {
        HTTPClient.shared.send(session.request) { result in
            switch result {
            case .success(let response):
                print(response.statusCode)
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
        SessionView(session: $session)
    }
}
