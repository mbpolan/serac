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
        
        CommandMenu("Request") {
            Button("Edit URL") {
                FocusURLNotification().notify()
            }
            .keyboardShortcut("l", modifiers: .command)
            
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
