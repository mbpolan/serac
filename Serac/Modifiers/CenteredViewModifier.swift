//
//  CenteredViewModifier.swift
//  Serac
//
//  Created by Mike Polan on 10/24/21.
//

import Foundation
import SwiftUI

// MARK: - View Modifier

struct CenteredViewModifier: ViewModifier {
    let axis: Axis
    
    func body(content: Content) -> some View {
        if axis == .horizontal {
            HStack {
                Spacer()
                content
                Spacer()
            }
        } else if axis == .vertical {
            VStack {
                Spacer()
                content
                Spacer()
            }
        } else {
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    content
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}

// MARK: - Extensions

extension CenteredViewModifier {
    enum Axis {
        case horizontal
        case vertical
        case both
    }
}

extension View {
    func centered(_ axis: CenteredViewModifier.Axis) -> some View {
        modifier(CenteredViewModifier(axis: axis))
    }
}
