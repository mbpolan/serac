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
            Button("Toggle Quick Search") {
                ToggleCommandPaletteNotification(mode: .search).notify()
            }
            .keyboardShortcut("o", modifiers: [.command, .shift])
            
            Button("Toggle Command Palette") {
                ToggleCommandPaletteNotification(mode: .command).notify()
            }
            .keyboardShortcut("p", modifiers: [.command, .shift])
        }
        
        CommandMenu("Request") {
            Button("Edit URL") {
                FocusURLNotification().notify()
            }
            .keyboardShortcut("l", modifiers: .command)
            
            Menu("Jump to...") {
                Button("Authentication") {
                    FocusRequestControlNotification(control: .authentication).notify()
                }
                .keyboardShortcut("a", modifiers: [.control, .option])
                
                Button("Headers") {
                    FocusRequestControlNotification(control: .headers).notify()
                }
                .keyboardShortcut("h", modifiers: [.control, .option])
                
                Button("Body") {
                    FocusRequestControlNotification(control: .body).notify()
                }
                .keyboardShortcut("b", modifiers: [.control, .option])
                
                Button("Query Parameters") {
                    FocusRequestControlNotification(control: .parameters).notify()
                }
                .keyboardShortcut("q", modifiers: [.control, .option])
            }
            
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
