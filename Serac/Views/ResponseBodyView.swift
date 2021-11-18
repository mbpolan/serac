//
//  ResponseBodyView.swift
//  Serac
//
//  Created by Mike Polan on 10/26/21.
//

import SwiftUI

// MARK: - View

struct ResponseBodyView: View {
    @ObservedObject var response: Response
    
    var body: some View {
        VStack {
            if response.contentType != .none {
                SyntaxTextView(data: data,
                               isEditable: false,
                               adaptor: adaptor,
                               observeVariables: false)
            } else {
                Text("No data")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var hasBody: Bool {
        response.contentType != .none
    }
    
    private var data: Binding<Data> {
        .init(
            get: { response.data ?? Data() },
            set: { _ in })
    }
    
    private var adaptor: Binding<SyntaxAdaptor> {
        .init(
            get: {
                switch response.contentType {
                case .json:
                    return JSONSyntaxAdaptor(prettyPrint: true)
                default:
                    return NoopSyntaxAdaptor()
                }
            },
            set: { _ in })
    }
}

// MARK: - Preview
struct ResponseBodyView_Preview: PreviewProvider {
    static var previews: some View {
        ResponseBodyView(response: Response())
    }
}
