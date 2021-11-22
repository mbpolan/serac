//
//  RequestBodyView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct RequestBodyView: View {
    @AppStorage("activeVariableSet") private var activeVariableSet: String?
    @AppStorage("variableSets") private var variableSets: [VariableSet] = []
    @ObservedObject var request: Request
    
    var body: some View {
        VStack {
            HStack {
                // if the current request body content type supports pretty printing, show
                // a button to allow doing so on demand
                if canFormat {
                    Button(action: handleFormat) {
                        Image(systemName: "paintbrush")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Reformat the request body")
                }
                
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
                if request.bodyContentType == .formURLEncoded {
                    FormDataRequestBodyView(request: request)
                } else if request.bodyContentType != .none {
                    SyntaxTextView(string: $request.body,
                                   isEditable: true,
                                   formatter: formatter,
                                   observeVariables: true,
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
    
    private var canFormat: Bool {
        request.bodyContentType == .json
    }
    
    private var variables: VariableSet? {
        variableSets.first(where: { $0.id == activeVariableSet ?? "" })
    }
    
    private var formatter: Binding<TextFormatter> {
        .init(
            get: {
                switch request.bodyContentType {
                case .json:
                    return .init(adaptors: [
                        JSONFormatAdaptor(),
                        VariableFormatAdaptor(variables: variables)
                    ])
                default:
                    return .init(adaptors: [
                        VariableFormatAdaptor(variables: variables)
                    ])
                }
            },
            set: { _ in })
    }
    
    private func handleFormat() {
        request.body = TextFormatter(adaptors: [
            JSONPrettyPrintFormatAdaptor(),
            JSONFormatAdaptor(),
            VariableFormatAdaptor(variables: variables)
        ])
            .apply(to: request.body)
            .string
    }
    
    private func handlePersistState() {
        PersistAppStateNotification().notify()
    }
    
    private func requestBodyTypeText(_ type: RequestBodyType) -> String {
        switch type {
        case .none:
            return "None"
        case .text:
            return "Text"
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
            .previewDisplayName("None")
    }
}
