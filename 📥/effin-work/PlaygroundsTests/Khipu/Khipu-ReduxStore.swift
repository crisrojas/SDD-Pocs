//
//  Khipu-ReduxStore.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 18/11/23.
//
import XCTest
import Foundation

/// Quiero tener un store similar al de Khipu con una api diferente para el método update.
/// Similar a la de la implementación de Redux de Jim Lai
/// store.update {
///     $0
///         .map { $0.greetigs = "hello" }
///         .map { $0.goodbys = "ok, bye"}
/// }
/// Lo más similar que he conseguido es esto
fileprivate struct AppState {
    var users = [UUID: User]()
    enum Path {
        case user(UUID)
    }
    
    func delete(_ update: Path) {
        
    }
}

fileprivate final class StoreBis {
    var state = AppState() { didSet {notify()}}
    var callbacks = [()->Void]()
    
    func update(transform: (inout AppState) -> Void) {
        var copy = state
        transform(&copy)
        state = copy
    }
    
    func suscribe(block: @escaping () -> Void) {
        callbacks.append(block)
    }
    
    func notify() {
        callbacks.forEach { $0() }
    }
}

/// Lo que me permite hacer algo así:
fileprivate let store = StoreBis()

fileprivate func store_1() {
    let user = User(firstName: "Cristian", lastName: "Patiño Rojas")
    
    store.update { $0.delete(.user(user.id)) }
    
    /// Este enfoque solo funcionaría si la solución de persistencia fuese serialización al disko o serlialización completa
    
    store.update {
        $0.delete(.user(user.id))
        $0.users[user.id] = user
    }
    
    /// Tengo la sensación de que estamos haciendo esto:
    store.state.users[user.id] = user
    
    /// Por tanto creo que el protocolo Updatable tiene valor para el proyecto.
    /// Y es necesario para implementar un AppState porque la lógica del cambio que puede tomar el AppState
    /// está codificada en el enum. Lo que hace más legible enviar cambioss al store.
    ///
    /// Incluso en modelos normales, como ToDo (del proyecto Clón de Things), es de gran ayuda, porque las modifiaciones
    /// posibles a la entidad pueden ser complejas. Básicamente, codificamos las transformaciones del modelo.
    /// Si solo es remplazar algo, podemos utilizar el método map
}

final class StoreTests: XCTestCase {
    func testStore() {
        let store = StoreBis()
        XCTAssert(store.state.users.isEmpty)
        
        store.update { state in
            let user = User(firstName: "Cristian", lastName: "Rojas")
            state.users[user.id] = user
        }
        
        XCTAssertEqual(store.state.users.first?.value.firstName, "Cristian")
    }
}

import SwiftUI
@dynamicMemberLookup
struct Action<T> {
    var state: T
    
    subscript<V>(dynamicMember kp: WritableKeyPath<T, V>) -> V {
        get {
            state[keyPath: kp]
        }
        mutating set {
            state[keyPath: kp] = newValue
            debug(kp, newValue)
        }
    }
    
    func map(_ transform: (Action<T>) -> Void) -> Action<T> {
        let action = Action<T>(state: state)
        transform(action)
        return action
    }
    
    func debug<V>(_ kp: WritableKeyPath<T, V>, _ v: V) {
        #if DEBUG
        let mirror = Mirror(reflecting: state)
        for c in mirror.children {
            guard c.value as AnyObject === state[keyPath: kp] as AnyObject else {continue}
            print("\(c.label ?? "") <- \(v)")
        }
        #endif
    }
}


protocol StoreProtocol: AnyObject {
    associatedtype State: Mappable, Codable
    var state: State {get set}
    var action: Action<State> {get}
    var callbacks: [()->Void] { get set }
    func effect(desc: String, _ transform: (inout Action<State>) -> Void)
    func write()
}

extension StoreProtocol {
    var action: Action<State> { .init(state: state) }
    func subscribe(subscriber: @escaping () -> Void) {
        callbacks.append(subscriber)
    }
    
    func effect(desc: String = #function, _ transform: (inout Action<State>) -> Void) {
        var copy = action
        transform(&copy)
        state = copy.state
    }
    
    func notifyCallbacks() { callbacks.forEach { $0() } }
}

//fileprivate class ReduxStore: StoreProtocol {
//    var state = AppState() { didSet {notifyCallbacks()} }
//    var callbacks: [() -> Void] = []
//    func write() {}
//}
//
//func reduxStore() {
//    let reduxStore = ReduxStore()
//    let user = User(firstName: "Cristian", lastName: "Rojas")
////    reduxStore.effect(
////        { $0.users[user.id] = user }
////    )
//}
