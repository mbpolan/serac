//
//  DynamicRequestBodyView.swift
//  Serac
//
//  Created by Mike Polan on 11/26/21.
//

import SwiftUI

// MARK: - View

struct DynamicRequestBodyView: View {
    @ActiveVariableSet private var variables: VariableSet?
    @StateObject private var viewModel: DynamicRequestBodyViewModel = DynamicRequestBodyViewModel()
    @ObservedObject var request: Request
    
    var body: some View {
        SyntaxTextView(string: $request.body,
                       isEditable: true,
                       formatter: formatter,
                       observeVariables: true,
                       introspect: { viewModel.textView = $0 },
                       onCommit: handlePersistState)
            .onFocusRequestBody {
                viewModel.textView?.becomeFirstResponder()
            }
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
    
    private func handlePersistState() {
        PersistAppStateNotification().notify()
    }
}

// MARK: - View Model

class DynamicRequestBodyViewModel: ObservableObject {
    @Published var textView: NSView?
}

// MARK: - Preview

struct DynamicRequestBodyView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    
    static var previews: some View {
        DynamicRequestBodyView(request: request)
    }
}
