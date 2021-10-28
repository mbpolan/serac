//
//  Events.swift
//  Serac
//
//  Created by Mike Polan on 10/27/21.
//

import Combine
import SwiftUI

protocol Notifiable {
    static var name: Notification.Name { get }
    func notify()
}

struct SendRequestNotification: Notifiable {
    static var name = Notification.Name("sendRequest")
    
    func notify() {
        NotificationCenter.default.post(name: SendRequestNotification.name, object: nil)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: SendRequestNotification.name, object: nil)
    }
}

extension View {
    func onNotification(_ name: Notification.Name, perform: @escaping() -> Void) -> some View {
        return onReceive(NotificationCenter.default.publisher(for: name)) { event in
            perform()
        }
    }
    
    func onSendRequest(perform: @escaping() -> Void) -> some View {
        return onNotification(SendRequestNotification.name, perform: perform)
    }
}
