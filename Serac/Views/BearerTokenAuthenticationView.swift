//
//  BearerTokenAuthenticationView.swift
//  Serac
//
//  Created by Mike Polan on 11/15/21.
//

import SwiftUI

// MARK: - View

struct BearerTokenAuthenticationView: View {
    @ObservedObject var request: Request
    
    var body: some View {
        GeometryReader { geo in
            LazyVGrid(columns: [
                .init(.flexible(minimum: 100)),
                .init(.flexible(minimum: 250))
            ]) {
                Text("Bearer Token")
                TextField(text: $request.authentication.bearer.token)
            }
            .frame(width: geo.size.width / 2, alignment: .center)
            .centered(.horizontal)
        }
    }
}

// MARK: - Preview

struct BearerTokenAuthenticationView_Preview: PreviewProvider {
    @State static var request = Request()
    
    static var previews: some View {
        BearerTokenAuthenticationView(request: request)
    }
}
