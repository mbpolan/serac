//
//  HeadersView.swift
//  Serac
//
//  Created by Mike Polan on 10/25/21.
//

import SwiftUI

// MARK: - View

struct HeadersView: View {
    let editable: Bool
    @ObservedObject var message: HTTPMessage
    
    var body: some View {
        ScrollView {
            KeyValueTableView(data: $message.headers,
                              labels: ["Header", "Value"],
                              editable: true)
                .padding([.leading, .trailing], 10)
        }
    }
}

// MARK: - Preview

struct HeadersView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        request.headers = []
        return HeadersView(editable: true, message: request)
    }
}
