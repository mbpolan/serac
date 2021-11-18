//
//  NSMutableAttributedString.swift
//  Serac
//
//  Created by Mike Polan on 11/17/21.
//

import SwiftUI

extension NSMutableAttributedString {
    func decorateVariables(variables: VariableSet) -> NSMutableAttributedString {
        let text = self.string
        let fullRange = NSRange(text.startIndex..., in: text)
        
        // look for embedded variables
        guard let match = try! NSRegularExpression(pattern: #"(\$\{.*\})"#)
                .matches(in: text, range: fullRange).first else {
                    return self
                }
        
        for index in 0..<match.numberOfRanges {
            let matched = match.range(at: index)
            
            // extract the variable name between the curly braces
            let variableName = NSMakeRange(matched.lowerBound + 2, matched.length - 3)
            
            if let substring = Range(variableName, in: text) {
                let variable = String(text[substring])
                
                // is this variable defined in our current variable set?
                if let variable = variables.variables.first(where: { $0.key == variable }) {
                    self.addAttributes([
                        .toolTip: variable.value as NSString,
                        .cursor: NSCursor.pointingHand,
                        .foregroundColor: NSColor.systemOrange,
                    ], range: matched)
                    
                } else {
                    self.addAttributes([
                        .foregroundColor: NSColor.systemRed,
                    ], range: matched)
                }
            }
        }
        
        return self
    }
}
