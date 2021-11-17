//
//  AppTextField.swift
//  Serac
//
//  Created by Mike Polan on 11/16/21.
//

import SwiftUI

// MARK: - View

// wrapper for a plain NSTextField that allows introspecting the underlying AppKit
// control after creation
struct AppTextField: NSViewRepresentable {
    @Binding var text: String
    var introspect: (_ nsTextField: NSTextField) -> Void = { _ in }
    var onCommit: () -> Void = { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.delegate = context.coordinator
        field.font = .systemFont(ofSize: NSFont.systemFontSize)
        introspect(field)
        
        return field
    }
    
    func updateNSView(_ field: NSTextField, context: Context) {
        if text != field.stringValue {
            field.stringValue = text
        }
    }
}

// MARK: - Coordinator

extension AppTextField {
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        let parent: AppTextField
        
        init(_ parent: AppTextField) {
            self.parent = parent
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            
            self.parent.text = field.stringValue
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            
            self.parent.text = field.stringValue
            self.parent.onCommit()
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            
            self.parent.text = field.stringValue
        }
    }
}

// MARK: - Preview

struct AppTextField_Preview: PreviewProvider {
    @State static var text: String = ""
    
    static var previews: some View {
        AppTextField(text: $text)
    }
}
