//
//  VariableTextField.swift
//  Serac
//
//  Created by Mike Polan on 11/21/21.
//

import SwiftUI

// MARK: - View

struct VariableTextField: View {
    @ActiveVariableSet private var variables: VariableSet?
    @Binding var text: String
    
    var body: some View {
        AppTextField(text: $text,
                     formatter: formatter)
    }
    
    private var formatter: TextFormatter {
        TextFormatter(adaptors: [
            VariableFormatAdaptor(variables: variables)
        ])
    }
}

// MARK: - Preview

struct VariableTextField_Preview: PreviewProvider {
    @State static var text: String = "foo ${bar}"
    
    static var previews: some View {
        VariableTextField(text: $text)
    }
}
