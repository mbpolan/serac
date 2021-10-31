//
//  RequestBodyView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct RequestBodyView: View {
    @ObservedObject var request: Request
    @State private var requestBody: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Picker(selection: $request.bodyContentType, label: Text("")) {
                    ForEach(RequestBodyType.allCases, id: \.self) { type in
                        Text(requestBodyTypeText(type))
                            .tag(type)
                    }
                }
                .frame(maxWidth: 100)
            }
            .layoutPriority(1)
            .padding([.leading, .trailing], 5)
            
            VStack {
                if request.bodyContentType != .none {
                    SyntaxTextView(string: $requestBody, isEditable: true, adaptor: adaptor)
                } else {
                    VStack {
                        Spacer()
                    Text("")
                        Spacer()
                    }
                }
            }
            .layoutPriority(2)
        }
        .onChange(of: requestBody) { body in
            request.body = body
        }
    }
    
    private var adaptor: Binding<SyntaxAdaptor> {
        .init(
            get: {
                switch request.bodyContentType {
                case .json:
                    return JSONSyntaxAdaptor()
                default:
                    return NoopSyntaxAdaptor()
                }
            },
            set: { _ in })
    }
    
    private func requestBodyTypeText(_ type: RequestBodyType) -> String {
        switch type {
        case .none:
            return "None"
        case .raw:
            return "Raw"
        case .json:
            return "JSON"
        case .formURLEncoded:
            return "Form"
        }
    }
}

// MARK: - Preview

struct RequestBodyView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        RequestBodyView(request: request)
    }
}
