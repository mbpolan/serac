//
//  AuthenticationView.swift
//  Serac
//
//  Created by Mike Polan on 11/10/21.
//

import SwiftUI

// MARK: - View

struct AuthenticationView: View {
    @ObservedObject var request: Request
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Picker("", selection: $request.authenticationType) {
                    ForEach(RequestAuthenticationType.allCases, id: \.self) { type in
                        Text(authenticationTypeText(type))
                            .tag(type)
                    }
                }
                .frame(width: 100)
            }
            .padding([.leading, .trailing], 5)
            
            if request.authenticationType == .none {
                EmptyView()
            } else if request.authenticationType == .basic {
                BasicAuthenticationView(request: request)
            }
            
            Spacer()
        }
        .onChange(of: request.authenticationType) { _ in
            PersistAppStateNotification().notify()
        }
    }
    
    private func authenticationTypeText(_ type: RequestAuthenticationType) -> String {
        switch type {
        case .none:
            return "None"
        case .basic:
            return "Basic"
        }
    }
}

// MARK: - Preview

struct AuthenticationView_Previews: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        AuthenticationView(request: request)
    }
}
