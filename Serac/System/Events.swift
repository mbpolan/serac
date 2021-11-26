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

struct ImportDataNotification: Notifiable {
    static var name = Notification.Name("importDataNotification")
    
    let type: SourceDataType
    
    enum SourceDataType {
        case postmanCollectionV21
    }
    
    func notify() {
        NotificationCenter.default.post(name: ImportDataNotification.name, object: type)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: ImportDataNotification.name, object: nil)
    }
}

struct OpenCollectionItemNotification: Notifiable {
    static var name = Notification.Name("openRequest")
    
    let item: CollectionItem
    
    func notify() {
        NotificationCenter.default.post(name: OpenCollectionItemNotification.name, object: item)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: SendRequestNotification.name, object: nil)
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

struct FocusURLNotification: Notifiable {
    static var name = Notification.Name("focusURL")
    
    func notify() {
        NotificationCenter.default.post(name: FocusURLNotification.name, object: nil)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: FocusURLNotification.name, object: nil)
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

struct ToggleQuickFindNotification: Notifiable {
    static var name = Notification.Name("toggleQuickFind")
    
    func notify() {
        NotificationCenter.default.post(name: ToggleQuickFindNotification.name, object: nil)
    }
    
    var publisher: NotificationCenter.Publisher {
        NotificationCenter.default.publisher(for: ToggleQuickFindNotification.name, object: nil)
    }
}

extension View {
    func onNotification(_ name: Notification.Name, perform: @escaping() -> Void) -> some View {
        return onReceive(NotificationCenter.default.publisher(for: name)) { event in
            perform()
        }
    }
    
    func onNotification<T>(_ name: Notification.Name, perform: @escaping(_ object: T) -> Void) -> some View {
        return onReceive(NotificationCenter.default.publisher(for: name, object: nil)) { event in
            guard let object = event.object as? T else { return }
            perform(object)
        }
    }
    
    func onPersistAppState(perform: @escaping() -> Void) -> some View {
        return onNotification(PersistAppStateNotification.name, perform: perform)
    }
    
    func onOpenCollectionItem(perform: @escaping(_ item: CollectionItem) -> Void) -> some View {
        return onNotification(OpenCollectionItemNotification.name, perform: perform)
    }
    
    func onSendRequest(perform: @escaping() -> Void) -> some View {
        return onNotification(SendRequestNotification.name, perform: perform)
    }
    
    func onFocusURLField(perform: @escaping() -> Void) -> some View {
        return onNotification(FocusURLNotification.name, perform: perform)
    }
    
    func onCloseRequest(perform: @escaping() -> Void) -> some View {
        return onNotification(CloseRequestNotification.name, perform: perform)
    }
    
    func onClearSessions(perform: @escaping() -> Void) -> some View {
        return onNotification(ClearSessionsNotification.name, perform: perform)
    }
    
    func onImportData(perform: @escaping(_ type: ImportDataNotification.SourceDataType) -> Void) -> some View {
        return onNotification(ImportDataNotification.name, perform: perform)
    }
    
    func onToggleQuickFind(perform: @escaping() -> Void) -> some View {
        return onNotification(ToggleQuickFindNotification.name, perform: perform)
    }
}
