//
//  TextField.swift
//  Serac
//
//  Created by Mike Polan on 11/11/21.
//

import SwiftUI

extension TextField where Label == Text {
    init(text: Binding<String>) {
        self.init("", text: text, onCommit: {
            PersistAppStateNotification().notify()
        })
    }
}
