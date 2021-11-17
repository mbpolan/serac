//
//  URLTextField.swift
//  Serac
//
//  Created by Mike Polan on 11/15/21.
//

import SwiftUI

// MARK: - View

struct URLTextField: NSViewRepresentable {
    @AppStorage("variableSets") var variableSets: [VariableSet] = []
    @EnvironmentObject var appState: AppState
    
    @Binding var text: String
    var introspect: (_ nsTextField: NSTextField) -> Void = { _ in }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.attributedStringValue = attributedString
        field.bezelStyle = .roundedBezel
        field.allowsEditingTextAttributes = true
        field.delegate = context.coordinator
        
        introspect(field)
        
        return field
    }
    
    func updateNSView(_ field: NSTextField, context: Context) {
        field.attributedStringValue = attributedString
    }
    
    var attributedString: NSMutableAttributedString {
        var str = NSMutableAttributedString(string: text)
        let fullRange = NSRange(text.startIndex..., in: text)
        
        // set default font
        str.addAttribute(.font,
                         value: NSFont.userFixedPitchFont(ofSize: NSFont.systemFontSize),
                         range: fullRange)
        
        // and a baseline foreground color
        str.addAttribute(.foregroundColor,
                         value: NSColor.textColor,
                         range: fullRange)
        
        str = decorateURL(str)
        str = decorateVariables(str)
        
        return str
    }
    
    private func decorateURL(_ str: NSMutableAttributedString) -> NSMutableAttributedString {
        let fullRange = NSRange(text.startIndex..., in: text)
        
        // parse the url and extract components
        let regex = try! NSRegularExpression(pattern: #"^(?<protocol>[^:]+://)(?<host>[^:/]+)(?<port>:[0-9]+)?(?<path>[^?]*)(?<query>\?.*)?.*$"#,
                                             options: .caseInsensitive)
        
        guard let match = regex.matches(in: text, range: fullRange).first else {
            return str
        }
        
        // apply colors for the various matched url components
        str.addAttribute(.foregroundColor,
                         value: NSColor.systemGray,
                         range: match.range(withName: "protocol"))
        
        str.addAttribute(.foregroundColor,
                         value: NSColor.systemMint,
                         range: match.range(withName: "host"))
        
        str.addAttribute(.foregroundColor,
                         value: NSColor.systemIndigo,
                         range: match.range(withName: "port"))
        
        str.addAttribute(.foregroundColor,
                         value: NSColor.systemTeal,
                         range: match.range(withName: "query"))
        
        return str
    }
    
    private func decorateVariables(_ str: NSMutableAttributedString) -> NSMutableAttributedString {
        let fullRange = NSRange(text.startIndex..., in: text)
        
        // look for embedded variables
        guard let match = try! NSRegularExpression(pattern: #"(\$\{.*\})"#)
                .matches(in: text, range: fullRange).first else {
                    return str
                }
        
        for index in 0..<match.numberOfRanges {
            let matched = match.range(at: index)
            
            // extract the variable name between the curly braces
            let variableName = NSMakeRange(matched.lowerBound + 2, matched.length - 3)
            
            if let substring = Range(variableName, in: text) {
                let variable = String(text[substring])
                
                // is this variable defined in our current variable set?
                if let selectedVariableSet = appState.variableSet,
                   let variableSet = variableSets.first(where: { $0.id == selectedVariableSet }),
                   let value = variableSet.variables.first(where: { $0.key == variable }) {
                    
                    str.addAttributes([
                        .attachment: value,
                        .foregroundColor: NSColor.systemOrange,
                    ], range: matched)
                } else {
                    str.addAttributes([
                        .foregroundColor: NSColor.systemRed,
                    ], range: matched)
                }
            }
        }
        
        return str
    }
}

// MARK: - Coordinator

extension URLTextField {
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: URLTextField
        
        init(_ parent: URLTextField) {
            self.parent = parent
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            guard let view = obj.object as? NSTextField else {
                return
            }
            
            self.parent.text = view.attributedStringValue.string
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let view = obj.object as? NSTextField else {
                return
            }
            
            self.parent.text = view.attributedStringValue.string
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            guard let view = obj.object as? NSTextField else {
                return
            }
            
            self.parent.text = view.attributedStringValue.string
            PersistAppStateNotification().notify()
        }
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
