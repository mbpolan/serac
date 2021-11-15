//
//  SyntaxAdaptor.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

protocol SyntaxAdaptor {
    func decorate(_ text: String) -> NSMutableAttributedString
    func update(string: String) -> String
}

struct NoopSyntaxAdaptor: SyntaxAdaptor {
    
    func decorate(_ text: String) -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(text.startIndex..., in: text)
        
        // set default foreground color and font
        attributedString.addAttribute(.font, value: NSFont.userFixedPitchFont(ofSize: 14), range: fullRange)
        attributedString.addAttribute(.foregroundColor, value: NSColor.textColor, range: fullRange)
        
        return attributedString
    }
    
    func update(string: String) -> String {
        return string
    }
}

struct JSONSyntaxAdaptor: SyntaxAdaptor {
    var prettyPrint: Bool = false
    
    func decorate(_ rawText: String) -> NSMutableAttributedString {
        var text = rawText
        
        // pretty print the json string
        if prettyPrint,
           let data = text.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data, options: []),
           let json = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .withoutEscapingSlashes]) {
            text = String(decoding: json, as: UTF8.self)
        }
        
        let attributedString = NSMutableAttributedString(string: text)
        let fullRange = NSRange(text.startIndex..., in: text)
        
        // set default font
        attributedString.addAttribute(.font, value: NSFont.userFixedPitchFont(ofSize: 14), range: fullRange)
        
        // set a default foreground color
        attributedString.addAttribute(.foregroundColor,
                                      value: NSColor.textColor,
                                      range: fullRange)
        
        // find tokens that represent json numbers
        let numberRegex = try! NSRegularExpression(pattern: "([0-9]+)")
        numberRegex.matches(in: text,
                            range: NSRange(text.startIndex..., in: text)).forEach { match in
            attributedString.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: match.range)
        }
        
        // find tokens that represent json strings
        let stringRegex = try! NSRegularExpression(pattern: #""([^"\\]*(?:\\.[^"\\]*)*)""#)
        stringRegex.matches(in: text,
                            range: NSRange(text.startIndex..., in: text)).forEach { match in
            attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: match.range)
        }
        
        let booleanRegex = try! NSRegularExpression(pattern: #":[\s\n\t]*(false|true)"#)
        booleanRegex.matches(in: text,
                            range: NSRange(text.startIndex..., in: text)).forEach { match in
            attributedString.addAttribute(.foregroundColor, value: NSColor.systemTeal, range: match.range)
        }
        
        return attributedString
    }
    
    func update(string: String) -> String {
        if string == "{" {
            // insert a closing brace automatically
            return "{\n}"
        } else {
            return string
        }
    }
}
