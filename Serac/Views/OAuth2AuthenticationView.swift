//
//  OAuth2AuthenticationView.swift
//  Serac
//
//  Created by Mike Polan on 11/11/21.
//

import SwiftUI

// MARK: - View

struct OAuth2AuthenticationView: View {
    @ObservedObject var request: Request
    
    var body: some View {
        GeometryReader { geo in
            LazyVGrid(columns: [
                .init(.flexible(minimum: 100)),
                .init(.flexible(minimum: 250)),
            ]) {
                Text("Token URL")
                VariableTextField(text: $request.authentication.oauth2.tokenURL)
                
                Text("Client ID")
                VariableTextField(text: $request.authentication.oauth2.clientId)
                
                Text("Client Secret")
                SecureField(text: $request.authentication.oauth2.clientSecret)
                
                Text("Scope")
                VariableTextField(text: $request.authentication.oauth2.scope)
                
                Text("Grant Type")
                VariableTextField(text: $request.authentication.oauth2.grantType)
            }
            .frame(width: geo.size.width / 2, alignment: .center)
            .centered(.horizontal)
        }
    }
}

// MARK: - Preview

struct OAuth2AuthenticationView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        OAuth2AuthenticationView(request: request)
    }
}
