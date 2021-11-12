//
//  AppCommands.swift
//  Serac
//
//  Created by Mike Polan on 10/27/21.
//

import SwiftUI

struct AppCommands: Commands {
    
    var body: some Commands {
        CommandMenu("Request") {
            Button("Send") {
                SendRequestNotification().notify()
            }
            .keyboardShortcut(.return, modifiers: .command)
            
            Button("Close") {
                CloseRequestNotification().notify()
            }
            .keyboardShortcut("w", modifiers: .command)
            
            Divider()
            
            Button("Clear Sessions") {
                ClearSessionsNotification().notify()
            }
        }
    }
}
