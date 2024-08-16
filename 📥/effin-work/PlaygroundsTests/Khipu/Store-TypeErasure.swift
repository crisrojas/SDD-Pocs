//
//  Store.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 15/11/23.
//

import Foundation
/// *Test*
/// **Test**
/// ~~Test~~
/// ==test==
/// ::test::
/// Test[1]
func mappable() {
    _ = AppState().map {
        let user = User(firstName: "Cristian", lastName: "lastName")
        $0.users[user.id] = user
    }
}

fileprivate struct AppState: Initializable, Mappable {
    var users = [UUID: User]()
}

extension AppState {
    
    enum Delete {
        case user(UUID)
    }
    
    mutating func delete(_ command: Delete) {
        switch command {
        case .user(let id): users[id] = nil
        }
    }
    mutating func delete(userId: UUID) {
        users[userId] = nil
    }
}
// Upsert Delete Command
enum UDCommand<T> {
    case upsert(T)
    case delete(T)
}

/// Updatable API
/// AppState is mutated through it and immediately persisted through a store owner
extension AppState: Updatable, Codable {
    typealias UpdateType = Update
    func updated(_ update: Update) -> AppState {self}
    mutating func update(_ update: Update) {}
    
    enum Update {
        case user(UDCommand<User>)
        case other
    }
    
    func update(_ update: Update) -> AppState {
        switch update {
        case .user(let command): return handleUserCommand(command)
        default: return self
        }
    }
    
    func handleUserCommand(_ command: UDCommand<User>) -> Self {
        var copy = self
        switch command {
        case .upsert(let user): copy.users[user.id] = user
        case .delete(let user): copy.users[user.id] = nil
        }
        return copy
    }
}

protocol AppStoreProtocol: AnyObject {
    associatedtype State: StateProtocol
    var state: State { get set }
    var callbacks: [()->Void] { get set }
    func update(_ update: State.UpdateType)
    func write()
    func readFromSource() -> State
    func read()
    func subscribe(subscriber: @escaping () -> Void)
}

extension AppStoreProtocol {
    var state: State {
        get { state              } // @todo: no sé si esto funcione
        set { onChange(newValue) }
    }
    
    var callbacks: [()->Void] {
        get { callbacks            }
        set { callbacks = newValue }
    }
    
    func update(_ update: State.UpdateType) {
//        state = state.update(update)
        write()
    }
    
    func subscribe(subscriber: @escaping () -> Void) {
        callbacks.append(subscriber)
    }
    
    func notifySubscriptors() {
        callbacks.forEach { $0() }
    }
    
    func onChange(_ state: State) {
        self.state = state
        notifySubscriptors()
    }
    
    func read() {
        state = readFromSource()
    }
}

typealias StateProtocol = Updatable & Initializable

final class RamStore<T: StateProtocol>: AppStoreProtocol {
    typealias State = T
    func write() {}
    func readFromSource() -> T { .init() }
}

final class DiskStore<T: StateProtocol>: AppStoreProtocol {
    typealias State = T
    func write() {}
    func readFromSource() -> T { .init() }
}

final class CoreDataStore<T: StateProtocol>: AppStoreProtocol {
    typealias State = T
    func write() {}
    func readFromSource() -> T { .init() }
}

final class RealmStore<T: StateProtocol>: AppStoreProtocol {
    typealias State = T
    func write() {}
    func readFromSource() -> T { .init() }
}

final class SQLiteStore<T: StateProtocol>: AppStoreProtocol {
    typealias State = T
    func write() {}
    func readFromSource() -> T { .init() }
}

enum DataSource {
    case ram
    case disk
    case coreData
    case realm
    case sqlite
}

enum DataSourceBis {
    case ram
    case disk
    case coreData
    case realm
    case sqlite
}

class AbstractStore<T: StateProtocol>: AppStoreProtocol {
    typealias State = T
    func write() {
        fatalError("Must implement")
    }
    
    func readFromSource() -> T {
        fatalError("Must implement")
    }
}


protocol PersistencyManager {
    func write()
    func read()
}

final class StoreWrapper<T: StateProtocol>: AbstractStore<T> {
    let manager: PersistencyManager
    init(manager: PersistencyManager) {
        self.manager = manager
    }
}

// #type-erasure
final class GeneralStore<T: StateProtocol>: AppStoreProtocol {
    
    func write() {
        underlayingStore.write()
    }
    
    func readFromSource() -> T {
        underlayingStore.readFromSource() as! T
    }
    
    typealias State = T
    let underlayingStore: any AppStoreProtocol
    init(dataSource: DataSource) {
        underlayingStore = GeneralStore.makeStore(from: dataSource)
    }
    
    
    static func makeStore(from dataSource: DataSource) -> any AppStoreProtocol {
        switch dataSource {
        case .ram     : return RamStore     <T>()
        case .disk    : return DiskStore    <T>()
        case .realm   : return RealmStore   <T>()
        case .coreData: return CoreDataStore<T>()
        case .sqlite  : return SQLiteStore  <T>()
        }
    }
}

fileprivate func makeStore(dataSource: DataSource) {
    let store = GeneralStore<AppState>(dataSource: dataSource)
    store.subscribe { print("updated") }
    store.update(.user(.upsert(.init(firstName: "Cristian", lastName: "Rojas"))))
}

protocol UseCase {
    associatedtype RequestType
    func request(_ request: RequestType) throws
}

