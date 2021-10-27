//
//  ResponseBodyView.swift
//  Serac
//
//  Created by Mike Polan on 10/26/21.
//

import SwiftUI

// MARK: - View

struct ResponseBodyView: View {
    @State private var adaptor: SyntaxAdaptor = NoopSyntaxAdaptor()
    @State private var data: Data = Data()
    @State private var hasBody: Bool = true
    
    init(response: Response) {
        self._data = State(initialValue: response.data ?? Data())
        
        switch response.contentType {
        case .json:
            self._adaptor = State(initialValue: JSONSyntaxAdaptor())
        case .unknown:
            self._adaptor = State(initialValue: NoopSyntaxAdaptor())
        default:
            self._hasBody = State(initialValue: false)
        }
    }
    
    var body: some View {
        return Group {
            if hasBody {
                SyntaxTextView(data: $data,
                               isEditable: false,
                               adaptor: adaptor)
            } else {
                Text("No data")
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
struct ResponseBodyView_Preview: PreviewProvider {
    static var previews: some View {
        ResponseBodyView(response: Response())
    }
}
