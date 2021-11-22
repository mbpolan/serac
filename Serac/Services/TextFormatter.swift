//
//  FormatPipeline.swift
//  Serac
//
//  Created by Mike Polan on 11/20/21.
//

import SwiftUI

// MARK: - Text Formatter

struct TextFormatter {
    let adaptors: [FormatAdaptor]
    var options: Options? = .default
    
    static var none: TextFormatter {
        TextFormatter(adaptors: [])
    }
    
    func apply(to string: String) -> NSMutableAttributedString {
        var text = NSMutableAttributedString(string: string)
        var range = NSRange(string.startIndex..., in: string)
        
        // perform mutating formatting operations first
        text = adaptors.filter { $0.isMutating }.reduce(text, { memo, adaptor in
            return adaptor.decorate(memo, range: NSRange(location: 0, length: text.length))
        })
        
        // recompute the full text range
        range = NSRange(location: 0, length: text.length)
        
        // set default font
        if let font = options?.font {
            text.addAttribute(.font,
                              value: font,
                              range: range)
        }
        
        // and a baseline foreground color
        if let foregroundColor = options?.foregroundColor {
            text.addAttribute(.foregroundColor,
                              value: foregroundColor,
                              range: range)
        }
        
        // perform formatting operations that do not mutate the current string
        return adaptors.filter { !$0.isMutating }.reduce(text, { memo, adaptor in
            return adaptor.decorate(memo,
                                    range: range)
        })
    }
}

// MARK: - Extensions

extension TextFormatter {
    struct Options {
        let font: NSFont?
        let foregroundColor: NSColor?
        
        static var `default`: Options {
            Options(font: NSFont.systemFont(ofSize: NSFont.systemFontSize),
                    foregroundColor: .textColor)
        }
    }
}
