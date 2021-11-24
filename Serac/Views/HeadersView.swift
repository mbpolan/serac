//
//  HeadersView.swift
//  Serac
//
//  Created by Mike Polan on 10/25/21.
//

import SwiftUI

// MARK: - View

struct HeadersView: View {
    @ActiveVariableSet private var variables: VariableSet?
    @ObservedObject var message: HTTPMessage
    let editable: Bool
    
    var body: some View {
        ScrollView {
            KeyValueTableView(data: $message.headers,
                              labels: ["Header", "Value"],
                              editable: editable,
                              formatter: formatter)
                .padding([.leading, .trailing], 10)
        }
    }
    
    private var formatter: TextFormatter {
        if editable {
            return TextFormatter(adaptors: [
                VariableFormatAdaptor(variables: variables)
            ])
        }
        
        return .none
    }
}

// MARK: - Preview

struct HeadersView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        request.headers = []
        return HeadersView(message: request, editable: true)
    }
}
