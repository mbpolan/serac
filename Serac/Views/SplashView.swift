//
//  SplashView.swift
//  Serac
//
//  Created by Mike Polan on 11/12/21.
//

import SwiftUI

// MARK: - View

struct SplashView: View {
    var body: some View {
        VStack {
            Text("Create a request or open an existing one to get started")
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

struct SplashView_Preview: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
