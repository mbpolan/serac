//
//  JSONString.swift
//  Serac
//
//  Created by Mike Polan on 10/23/21.
//

import SwiftUI

struct JSONString {
    let attributedString: NSMutableAttributedString
    
    init(from text: String) {
        attributedString = NSMutableAttributedString(string: text)
        
        decorateString(text)
    }
    
    private func decorateString(_ text: String) {
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
        let stringRegex = try! NSRegularExpression(pattern: "(\"[^\"]*\")")
        stringRegex.matches(in: text,
                            range: NSRange(text.startIndex..., in: text)).forEach { match in
            attributedString.addAttribute(.foregroundColor, value: NSColor.systemGreen, range: match.range)
        }
    }
}
