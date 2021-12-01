//
//  AppCommands.swift
//  Serac
//
//  Created by Mike Polan on 10/27/21.
//

import SwiftUI

struct AppCommands: Commands {
    
    var body: some Commands {
        CommandGroup(before: .newItem) {
            Menu("Import...") {
                Button("Postman Collection v2.1") {
                    ImportDataNotification(type: .postmanCollectionV21).notify()
                }
            }
        }
        
        CommandGroup(before: .sidebar) {
            Button("Toggle Quick Find") {
                ToggleCommandPaletteNotification().notify()
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])
        }
        
        CommandMenu("Request") {
            Button("Edit URL") {
                FocusURLNotification().notify()
            }
            .keyboardShortcut("l", modifiers: .command)
            
            Button("Edit Body") {
                FocusRequestBodyNotification().notify()
            }
            .keyboardShortcut("b", modifiers: .command)
            
            Button("Format Body") {
                FormatRequestBodyNotification().notify()
            }
            .keyboardShortcut("i", modifiers: .control)
            
            Divider()
            
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
