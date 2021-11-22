//
//  AppTextField.swift
//  Serac
//
//  Created by Mike Polan on 11/16/21.
//

import SwiftUI

// MARK: - View

// a text field that allows formatting text, introspecting the underlying NSTextField
// control, and automatically persisting app state
struct AppTextField: NSViewRepresentable {
    @Binding var text: String
    var formatter: TextFormatter? = nil
    var introspect: (_ nsTextField: NSTextField) -> Void = { _ in }
    
    // by default this will persist app state on text commit. when providing your own function, be sure to
    // manually send an event to persist state if needed.
    var onCommit: () -> Void = { PersistAppStateNotification().notify() }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSTextField {
        let field = NSTextField()
        field.delegate = context.coordinator
        
        if let formatter = formatter {
            field.allowsEditingTextAttributes = true
            field.attributedStringValue = formatter.apply(to: text)
        } else {
            field.font = .systemFont(ofSize: NSFont.systemFontSize)
            field.stringValue = text
        }
        
        introspect(field)
        
        return field
    }
    
    func updateNSView(_ field: NSTextField, context: Context) {
        if let formatter = formatter {
            field.attributedStringValue = formatter.apply(to: text)
        } else {
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
            
            self.parent.text = text(field)
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            
            self.parent.text = text(field)
            self.parent.onCommit()
        }
        
        func controlTextDidChange(_ obj: Notification) {
            guard let field = obj.object as? NSTextField else { return }
            
            self.parent.text = text(field)
        }
        
        private func text(_ nsTextField: NSTextField) -> String {
            if parent.formatter == nil {
                return nsTextField.stringValue
            } else {
                return nsTextField.attributedStringValue.string
            }
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
