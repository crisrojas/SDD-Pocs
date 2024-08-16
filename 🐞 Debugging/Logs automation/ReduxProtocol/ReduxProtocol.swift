//
//  ReduxProtocol.swift
//  ReduxProtocol
//
//  Created by Cristian Felipe Patiño Rojas on 21/12/2023.
//

import SwiftUI

// Taken from
// https://gist.github.com/swift2931/6c9fb7fb828777a50860be2b9ae05fe0

protocol ReduxBase {
    associatedtype Store
    var binding: Binding<Store> {get}
}

extension ReduxBase {
    var action: Action<Store> {.init(binding: binding)}
    
    /// Effect can be used to system logs by taking a default value for its param
    /// which equals to the calling function. So it would need to be wrapped inside a method
    /// like
    ///
    /// func helloWorld()  {
    ///     effect(action.map { $0.hello = "world" })
    /// }
    func effect(desc: String = #function, _ action: Action<Store>) {
        binding.wrappedValue = action.binding.wrappedValue
    }
    
    func effect(desc: String = #function, _ map: (Action<Store>) -> Void) {
        binding.wrappedValue = action.map(map).binding.wrappedValue
    }
}

protocol Redux: ReduxBase {
    associatedtype Store
    var store: Store {get set}
}


protocol ReduxView: View, ReduxBase {
    associatedtype Store
    var store: State<Store> { get set }
}


extension ReduxView {
    var binding: Binding<Store> {
        Binding(
            get: { self.store.wrappedValue },
            set: { self.store.wrappedValue = $0 }
        )
    }
}


@dynamicMemberLookup
struct Action<T> {
    var binding: Binding<T>
    
    subscript<V>(dynamicMember kp: WritableKeyPath<T, V>) -> V {
        get {
            binding.wrappedValue[keyPath: kp]
        }
        nonmutating set {
            binding.wrappedValue[keyPath: kp] = newValue
            debug(kp, newValue)
        }
    }
    
    func map(_ transform: (Action<T>) -> Void) -> Action<T> {
        var s = binding.wrappedValue
        let b = Binding<T>(get: {s}, set: {s = $0})
        let action = Action<T>(binding: b)
        transform(action)
        return action
    }
    
    /// Prints which state has being mutated with the new value
    func debug<V>(_ kp: WritableKeyPath<T, V>, _ v: V) {
        #if DEBUG
        let mirror = Mirror(reflecting: binding.wrappedValue)
        for c in mirror.children {
            guard c.value as AnyObject === binding.wrappedValue[keyPath: kp] as AnyObject else {
                continue
            }
            print("\(Date()) - \(c.label ?? "") <- \(v)")
        }
        #endif
    }
}
