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

struct PersistAppStateNotification: Notifiable {
    static var name = Notification.Name("persistAppState")
    
    func notify() {
        NotificationCenter.default.post(name: PersistAppStateNotification.name, object: nil)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: PersistAppStateNotification.name, object: nil)
    }
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

struct CloseRequestNotification: Notifiable {
    static var name = Notification.Name("closeRequest")
    
    func notify() {
        NotificationCenter.default.post(name: CloseRequestNotification.name, object: nil)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: CloseRequestNotification.name, object: nil)
    }
}

struct ClearSessionsNotification: Notifiable {
    static var name = Notification.Name("clearSessions")
    
    func notify() {
        NotificationCenter.default.post(name: ClearSessionsNotification.name, object: nil)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: ClearSessionsNotification.name, object: nil)
    }
}

extension View {
    func onNotification(_ name: Notification.Name, perform: @escaping() -> Void) -> some View {
        return onReceive(NotificationCenter.default.publisher(for: name)) { event in
            perform()
        }
    }
    
    func onPersistAppState(perform: @escaping() -> Void) -> some View {
        return onNotification(PersistAppStateNotification.name, perform: perform)
    }
    
    func onSendRequest(perform: @escaping() -> Void) -> some View {
        return onNotification(SendRequestNotification.name, perform: perform)
    }
    
    func onCloseRequest(perform: @escaping() -> Void) -> some View {
        return onNotification(CloseRequestNotification.name, perform: perform)
    }
    
    func onClearSessions(perform: @escaping() -> Void) -> some View {
        return onNotification(ClearSessionsNotification.name, perform: perform)
    }
}
