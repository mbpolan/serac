//
//  ResponseView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct ResponseView: View {
    @Binding var response: Response?
    
    var body: some View {
        VStack {
            if let response = response {
                Text("Response!!!")
            } else {
                Spacer()
                
                Text("Nothing to see here")
                    .padding(15)
                
                Spacer()
            }
            // SyntaxTextView(text: $responseBody, isEditable: false)
        }
    }
}

// MARK: - Preview

struct ResponseView_Preview: PreviewProvider {
    @State static var response: Response? = Response()
    
    static var previews: some View {
        ResponseView(response: $response)
    }
}
