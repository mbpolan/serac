//
//  ActivityView.swift
//  Serac
//
//  Created by Mike Polan on 11/10/21.
//

import SwiftUI

// MARK: - View

struct ActivityView<Content>: View where Content: View {
    @Binding var loading: Bool
    let onAbort: () -> Void
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                content()
                    .blur(radius: loading ? 3 : 0)
                    .disabled(loading)
                    .allowsHitTesting(!loading)
                
                if loading {
                    VStack {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.bottom, 5)
                        
                        Button(action: onAbort) {
                            Text("Cancel")
                                .bold()
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
        }
    }
}

// MARK: - Preview

struct ActivityView_Previews: PreviewProvider {
    @State static var loading = true
    
    static var previews: some View {
        ActivityView(loading: $loading, onAbort: {}) {
            Text("Something lol")
                .centered(.both)
        }
    }
}
