//
//  URLTextFieldView.swift
//  Serac
//
//  Created by Mike Polan on 11/15/21.
//

import SwiftUI

// MARK: - View

struct URLTextFieldView: NSViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.attributedStringValue = attributedString
        field.bezelStyle = .roundedBezel
        field.allowsEditingTextAttributes = true
        field.delegate = context.coordinator
        
        return field
    }
    
    func updateNSView(_ field: NSTextField, context: Context) {
        field.attributedStringValue = attributedString
    }
    
    var attributedString: NSMutableAttributedString {
        let str = NSMutableAttributedString(string: text)
        let fullRange = NSRange(text.startIndex..., in: text)
        
        // set default font
        str.addAttribute(.font,
                         value: NSFont.userFixedPitchFont(ofSize: NSFont.systemFontSize),
                         range: fullRange)
        
        // and a baseline foreground color
        str.addAttribute(.foregroundColor,
                         value: NSColor.textColor,
                         range: fullRange)
        
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
}

// MARK: - Coordinator

extension URLTextFieldView {
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: URLTextFieldView
        
        init(_ parent: URLTextFieldView) {
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
        }
    }
}

// MARK: - Preview

struct URLTextFieldView_Preview: PreviewProvider {
    @State static var text: String = "https://mbpolan.com:8080/api/v1/users?query=foo=bar"
    
    static var previews: some View {
        URLTextFieldView(text: $text)
            .preferredColorScheme(.dark)
            .previewDisplayName("Dark")
        
        URLTextFieldView(text: $text)
            .preferredColorScheme(.light)
            .previewDisplayName("Light")
    }
}
