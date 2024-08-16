//
//  Redux.swift
//  PlaygroundsTests
//
//  Created by Cristian Felipe Patiño Rojas on 14/12/2023.
//

import Foundation

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
//
//struct ContentView: View, Redux {
//    @State private var internalState = MyState()  // Puedes reemplazar MyState con tu tipo de estado
//
//    var binding: Binding<MyState> {
//        $internalState
//    }
//
//    var body: some View {
//        VStack {
//            Text("Count: \(action.count)")  // Acceder a una propiedad del estado usando action
//            Button("Increment") {
//                effect("Increment count", action.map { $0.count += 1 })  // Modificar el estado usando effect
//            }
//        }
//    }
//}

struct MyState {
    var count: Int = 0
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
