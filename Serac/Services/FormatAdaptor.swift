//
//  FormatAdaptor.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import SwiftUI

// MARK: - Protocols
protocol FormatAdaptor {
    var isMutating: Bool { get }
    func decorate(_ text: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString
}

// MARK: - No-Op Format Adaptor

struct NoopFormatAdaptor: FormatAdaptor {
    var isMutating: Bool = false
    
    func decorate(_ text: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString {
        // set default foreground color and font
        text.addAttribute(.font, value: NSFont.userFixedPitchFont(ofSize: 14), range: range)
        text.addAttribute(.foregroundColor, value: NSColor.textColor, range: range)
        
        return text
    }
}

// MARK: - Variable Format Adaptor

struct VariableFormatAdaptor: FormatAdaptor {
    let variables: VariableSet
    
    init(variables: VariableSet?) {
        self.variables = variables ?? .empty
    }
    
    var isMutating: Bool = false
    
    func decorate(_ text: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString {
        // look for embedded variables
        let regex = try! NSRegularExpression(pattern: #"(\$\{.*\})"#)
        
        regex.matches(in: text.string, range: range).forEach { match in
            let matched = match.range
            
            // extract the variable name between the curly braces
            let variableName = NSMakeRange(matched.lowerBound + 2, matched.length - 3)
            
            guard let substring = Range(variableName, in: text.string) else { return }
            let variable = String(text.string[substring])
            
            // is this variable defined in our current variable set?
            if let variable = variables.variables.first(where: { $0.key == variable }) {
                text.addAttributes([
                    .toolTip: variable.value as NSString,
                    .cursor: NSCursor.pointingHand,
                    .foregroundColor: NSColor.systemOrange,
                ], range: matched)
                
            } else {
                text.addAttributes([
                    .foregroundColor: NSColor.systemRed,
                ], range: matched)
            }
        }
        
        return text
    }
}

// MARK: - URL Format Adaptor

struct URLFormatAdaptor: FormatAdaptor {
    var isMutating: Bool = false
    
    func decorate(_ text: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString {
        // parse the url and extract components
        let regex = try! NSRegularExpression(pattern: #"^(?<protocol>[^:]+://)(?<host>[^:/]+)(?<port>:[0-9]+)?(?<path>[^?]*)(?<query>\?.*)?.*$"#,
                                             options: .caseInsensitive)
        
        guard let match = regex.matches(in: text.string, range: range).first else {
            return text
        }
        
        // apply colors for the various matched url components
        text.addAttribute(.foregroundColor,
                          value: NSColor.systemGray,
                          range: match.range(withName: "protocol"))
        
        text.addAttribute(.foregroundColor,
                          value: NSColor.systemGreen,
                          range: match.range(withName: "host"))
        
        text.addAttribute(.foregroundColor,
                          value: NSColor.systemIndigo,
                          range: match.range(withName: "port"))
        
        text.addAttribute(.foregroundColor,
                          value: NSColor.systemTeal,
                          range: match.range(withName: "query"))
        
        return text
    }
}

struct JSONPrettyPrintFormatAdaptor: FormatAdaptor {
    var isMutating: Bool = true
    
    func decorate(_ text: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString {
        if let data = text.string.data(using: .utf8),
           let object = try? JSONSerialization.jsonObject(with: data, options: []),
           let json = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .withoutEscapingSlashes]) {
            return NSMutableAttributedString(string: String(decoding: json, as: UTF8.self))
        } else {
            return text
        }
    }
}

// MARK: - JSON Format Adaptor

struct JSONFormatAdaptor: FormatAdaptor {
    var isMutating: Bool = false
    
    func decorate(_ text: NSMutableAttributedString, range: NSRange) -> NSMutableAttributedString {
        // set default font
        text.addAttribute(.font, value: NSFont.userFixedPitchFont(ofSize: 14), range: range)
        
        // set a default foreground color
        text.addAttribute(.foregroundColor,
                          value: NSColor.textColor,
                          range: range)
        
        // find tokens that represent json numbers
        let numberRegex = try! NSRegularExpression(pattern: "([0-9]+)")
        numberRegex.matches(in: text.string, range: range).forEach { match in
            text.addAttribute(.foregroundColor, value: NSColor.systemPurple, range: match.range)
        }
        
        // find tokens that represent json strings
        let stringRegex = try! NSRegularExpression(pattern: #""([^"\\]*(?:\\.[^"\\]*)*)""#)
        stringRegex.matches(in: text.string, range: range).forEach { match in
            text.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: match.range)
        }
        
        let booleanRegex = try! NSRegularExpression(pattern: #":[\s\n\t]*(false|true)"#)
        booleanRegex.matches(in: text.string, range: range).forEach { match in
            text.addAttribute(.foregroundColor, value: NSColor.systemTeal, range: match.range)
        }
        
        return text
    }
}
