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
                HStack {
                    Button(action: handleCopyBody) {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .help("Copy response body to pasteboard")
                    
                    Spacer()
                }
                .padding([.leading, .trailing], 5)
                
                SyntaxTextView(data: data,
                               isEditable: false,
                               formatter: formatter,
                               observeVariables: false)
            } else {
                Text("No data")
                    .foregroundColor(.secondary)
            }
        }
        .onExportResponseBody(perform: handleExportBody)
    }
    
    private var hasBody: Bool {
        response.contentType != .none
    }
    
    private var data: Binding<Data> {
        .init(
            get: { response.data ?? Data() },
            set: { _ in })
    }
    
    private var formatter: Binding<TextFormatter> {
        .init(
            get: {
                switch response.contentType {
                case .json:
                    return .init(adaptors: [
                        JSONPrettyPrintFormatAdaptor(),
                        JSONFormatAdaptor()
                    ])
                default:
                    return .none
                }
            },
            set: { _ in })
    }
    
    private func handleExportBody(_ destination: ExportResponseBodyNotification.Destination) {
        switch destination {
        case .pasteboard:
            handleCopyBody()
        }
    }
    
    private func handleCopyBody() {
        guard let data = response.data else {
            NSSound.beep()
            return
        }
        
        NSPasteboard.general.prepareForNewContents(with: [])
        NSPasteboard.general.setString(String(decoding: data, as: UTF8.self),
                                       forType: .string)
    }
}

// MARK: - Preview
struct ResponseBodyView_Preview: PreviewProvider {
    static var previews: some View {
        ResponseBodyView(response: Response())
    }
}
