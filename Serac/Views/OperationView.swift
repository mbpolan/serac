//
//  OperationView.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - View

struct OperationView: View {
    @ObservedObject var request: Request
    @Binding var disableSend: Bool
    let onSend: (_ request: Request) -> Void
    
    var body: some View {
        HStack {
            Picker(selection: $request.method, label: Text("")) {
                ForEach(HTTPMethod.allCases, id: \.self) { verb in
                    Text(verb.rawValue)
                        .tag(verb)
                }
            }
            .frame(minWidth: 80)
            .layoutPriority(2)
            
            URLTextFieldView(text: $request.url)
                .layoutPriority(3)
            
            Button(action: { onSend(request) }) {
                Image(systemName: "paperplane.fill")
            }
            .disabled(disableSend)
            .padding(.trailing, 5)
            .layoutPriority(1)
        }
        .padding([.top, .trailing], 5)
        .padding([.bottom], 5)
    }
}

// MARK: - Preview

struct OperationView_Preview: PreviewProvider {
    @State static var request: Request = Request()
    @State static var loading: Bool = false
    
    static var previews: some View {
        OperationView(request: request,
                      disableSend: $loading,
                      onSend: { _ in })
    }
}
