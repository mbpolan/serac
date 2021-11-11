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
                    SyntaxTextView(string: $request.body,
                                   isEditable: true,
                                   adaptor: adaptor,
                                   onCommit: handlePersistState)
                } else {
                    EmptyView()
                        .centered(.vertical)
                }
            }
            .layoutPriority(2)
        }
        .onChange(of: request.bodyContentType) { _ in
            handlePersistState()
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
    
    private func handlePersistState() {
        PersistAppStateNotification().notify()
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
