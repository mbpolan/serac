//
//  ContentView.swift
//  Serac
//
//  Created by Mike Polan on 10/2/21.
//

import SwiftUI

struct ContentView: View {
    @State private var requestBody: String = ""
    @State private var responseBody: String = ""
    @State private var url: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Picker(selection: /*@START_MENU_TOKEN@*/.constant(1)/*@END_MENU_TOKEN@*/, label: /*@START_MENU_TOKEN@*/Text("Picker")/*@END_MENU_TOKEN@*/) {
                    /*@START_MENU_TOKEN@*/Text("1").tag(1)/*@END_MENU_TOKEN@*/
                    /*@START_MENU_TOKEN@*/Text("2").tag(2)/*@END_MENU_TOKEN@*/
                }
                
                TextField("", text: $url)
                
                Button("Send") {
                    
                }
            }
            
            HSplitView {
                SyntaxTextView(text: $requestBody, isEditable: true)
                SyntaxTextView(text: $responseBody, isEditable: false)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
