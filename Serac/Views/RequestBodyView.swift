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
    @State private var requestBodyType: RequestBodyType = .none
    @State private var requestBody: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("Request")
                
                Spacer()
                
                Picker(selection: $requestBodyType, label: Text("")) {
                    ForEach(RequestBodyType.allCases, id: \.self) { type in
                        Text(type.rawValue)
                            .tag(type)
                    }
                }
                .frame(maxWidth: 100)
            }
            .layoutPriority(1)
            .padding([.leading, .trailing], 5)
            
            VStack {
                if requestBodyType != .none {
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
    }
    
    private var adaptor: Binding<SyntaxAdaptor> {
        .init(
            get: {
                switch requestBodyType {
                case .json:
                    return JSONSyntaxAdaptor()
                default:
                    return NoopSyntaxAdaptor()
                }
            },
            set: { _ in })
    }
}

// MARK: - Preview

struct RequestBodyView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        RequestBodyView(request: request)
    }
}
