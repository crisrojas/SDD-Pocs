//
//  Khipu-ReduxStore.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 18/11/23.
//
import XCTest
import Foundation

// MARK: - Objetivo:
/// Quiero tener un store similar al de Khipu con una api diferente para el método update.
/// Similar a la de la implementación de Redux de Jim Lai
/// store.update {
///     $0
///         .map { $0.greetigs = "hello" }
///         .map { $0.goodbyes = "ok, bye"}
/// }
/// Lo más similar que he conseguido es esto
fileprivate struct AppState {
    var users = [UUID: User]()
}

fileprivate final class Store {
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

fileprivate func store_1() {
    let store = Store()
    var user = User(firstName: "Cristian", lastName: "Patiño Rojas")
    
    /// Utilización
    ///
    /// Create
    store.update {
        $0.users[user.id] = user
    }
    
    /// Update
    user.firstName = "Cristian Felipe"
    store.update {
        $0.users[user.id] = user
    }
    
    /// Delete
    store.update {
        $0.users[user.id] = nil
    }
    
    /// Probalbemente, este enfoque solo funcione si la solución de persistencia es la serialización al disco,
    /// porque estamos usanod swift para odificar un variable en memoria. Aunque podría explorar el enfoque con CoreData.
    ///
    /// Por otro lado,
    /// Tengo la sensación de que estamos haciendo esto, por lo que puede que el enfoque sea un poco redundante
    store.state.users[user.id] = user
    
    /// Por tanto creo que el protocolo Updatable tiene valor para el proyecto.
    /// Y para algunos casos complejos es necesario  implementar un enum porque la lógica del cambio se puede encapsular
    /// codificadadola en el enum.
    ///
    /// Por ejemplo, para la entidad  Todo del proyecto "Clón de Things", el enum Update es de gran ayuda, porque las modifiaciones
    /// posibles a la entidad pueden ser complejas. Básicamente, codificamos las transformaciones del modelo.
    /// Si solo es remplazar una variable simple, podemos, podemos utilizar el método map (update en este caso)
}

fileprivate final class StoreTests: XCTestCase {
    func testStore() {
        let store = Store()
        XCTAssert(store.state.users.isEmpty)
        
        store.update { state in
            let user = User(firstName: "Cristian", lastName: "Rojas")
            state.users[user.id] = user
        }
        
        XCTAssertEqual(store.state.users.first?.value.firstName, "Cristian")
    }
}

