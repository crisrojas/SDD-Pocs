//
//  Core-Member-Properties.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 16/11/23.
//

import Foundation

///
///En el contexto de la programación orientada a objetos, una “propiedad de miembro” o “member property” se refiere a una variable que es miembro de una clase o estructura.
///En otras palabras, es una variable que se declara dentro de una clase y que pertenece a los objetos de esa clase.
fileprivate enum Message {
    case add(User)
}

fileprivate struct AppState: Initializable {}
extension AppState: Updatable {
    enum Update {}
    func update(_ update: Update) -> AppState {
        
    }
}

fileprivate typealias Input = (Message) -> ()
fileprivate typealias Store = GeneralStore<AppState>

fileprivate protocol Feature: AnyObject {
    var store: Store? { get set }
    var body: Input { get }
}

extension Feature {
    func register(store: Store) {
        self.store = store
    }
}

fileprivate final class UserListFeature: Feature {
    
    var store: Store?
    
    var body: Input {{ [weak self] msg in
        guard let self else { return}
        switch msg {
        case .add(let user): self.add(user)
        }
    }}
    
    func add(_ user: User) {
//        store?.update(.user(.upsert(user)))
    }
    
    func delete(_ user: User) {
//        store?.update(.user(.delete(user)))
    }
}

fileprivate final class Core {
    
    let store: Store
    
    init(store: Store) {
        self.store = store
    }
    
    var features: [some Feature] {
        let features = [UserListFeature()]
        features.forEach { $0.register(store: store) }
        return features
    }
    
    
    var body: Input {{ [weak self] msg in
        guard let self else { return }
        features.forEach { feature in
//            feature.body
        }
    }}
}
