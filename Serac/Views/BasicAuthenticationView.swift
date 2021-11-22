//
//  BasicAuthenticationView.swift
//  Serac
//
//  Created by Mike Polan on 11/10/21.
//

import SwiftUI

// MARK: - View

struct BasicAuthenticationView: View {
    @ObservedObject var request: Request
    
    var body: some View {
        GeometryReader { geo in
            LazyVGrid(columns: [
                .init(.flexible(minimum: 150)),
                .init(.flexible(minimum: 150))
            ]) {
                Text("Username")
                VariableTextField(text: $request.authentication.basic.username)
                
                Text("Password")
                SecureField(text: $request.authentication.basic.password)
            }
            .frame(width: geo.size.width / 2, alignment: .center)
            .centered(.horizontal)
        }
    }
}

// MARK: - Preview

struct BasicAuthenticationView_Preview: PreviewProvider {
    @State static var request = Request()
    
    static var previews: some View {
        BasicAuthenticationView(request: request)
    }
}
