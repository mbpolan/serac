//
//  URLTextField.swift
//  Serac
//
//  Created by Mike Polan on 11/15/21.
//

import SwiftUI

// MARK: - View

struct URLTextField: View {
    @ActiveVariableSet var variables: VariableSet?
    @Binding var text: String
    var introspect: (_ nsTextField: NSTextField) -> Void = { _ in }
    
    var body: some View {
        AppTextField(text: $text,
                     formatter: formatter(variables),
                     introspect: { nsTextField in
            nsTextField.bezelStyle = .roundedBezel
            introspect(nsTextField)
        })
    }
    
    private func formatter(_ variables: VariableSet?) -> TextFormatter {
        return TextFormatter(adaptors: [
            URLFormatAdaptor(),
            VariableFormatAdaptor(variables: variables)
        ], options: .init(
            font: NSFont.userFixedPitchFont(ofSize: NSFont.systemFontSize),
            foregroundColor: .textColor))
    }
}

// MARK: - Preview

struct URLTextFieldView_Preview: PreviewProvider {
    @State static var text: String = "https://mbpolan.com:8080/api/v1/users?query=foo=bar"
    
    static var previews: some View {
        URLTextField(text: $text)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
        
        URLTextField(text: $text)
            .preferredColorScheme(.light)
            .previewDisplayName("Light")
    }
}
