//
//  ResponseErrorView.swift
//  Serac
//
//  Created by Mike Polan on 11/11/21.
//

import SwiftUI

// MARK: - View

struct ResponseErrorView: View {
    let message: String
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "xmark.circle")
                    .font(.system(size: 32))
                
                Text(message)
                    .bold()
                    .padding(.top, 3)
            }
            .centered(.both)
            .padding(15)
        }
    }
}

// MARK: - Preview

struct ResponseErrorView_Preview: PreviewProvider {
    static var previews: some View {
        ResponseErrorView(message: "Something went wrong")
    }
}
