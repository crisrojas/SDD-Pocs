//
//  Crud.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 15/11/23.
//

import Foundation

protocol CRUD: Updatable, Identifiable {
    func upsert() async throws
    func delete() async throws
    static func upsert(_ element: Self) async throws
    static func delete(_ element: Self) async throws
}


protocol FileCUD {}

struct User: Identifiable, Codable, Mappable {
    let id: UUID
    fileprivate(set) var firstName: String
    fileprivate(set) var lastName: String
}

extension User {
    init(firstName: String, lastName: String) {
        self.id = .init()
        self.firstName = firstName
        self.lastName = lastName
    }
}

extension User: Updatable {
    enum Update {
        case firstName(String)
        case lastName(String)
    }
    
    func update(_ update: Update) -> Self {
        switch update {
        case .firstName(let data): self.mapped { $0.firstName = data }
        case .lastName (let data): self.mapped { $0.lastName  = data }
        }
    }
}

/// This could be changed ot only two commands: upsert & delete
enum CUDCommand<T> {
    case create(T)
    case update(T)
    case delete(T)
}

enum UDCommand<T> {
    case upsert(T)
    case delete(T)
}



enum ContainerExample {
    static var appStore = GeneralStore<AppState>(dataSource: .disk)
}

extension User: CRUD {
    func upsert() async throws {}
    func delete() async throws {}
    
    /// El problema potencial que veo a las extensiones de protocolos y usarlas como Jam lai sugiere es
    /// que estamos usando en ellas dependencias implicitas.
    /// Podría solucionarse teniendo un Container al que se le inyectan dependencias en los tests
    static func upsert(_ element: User) async throws {
        ContainerExample.appStore.update(.user(.upsert(element)))
    }
    static func delete(_ element: User) async throws {
        ContainerExample.appStore.update(.user(.delete(element)))
    }
    
    /// Y en los tests ->
    /// ContainerExample.appStore = .init(dataSource: .ram)
}


func test() async throws {
    let user = try await ApiUser.getAll()

    let user2 = User(id: .init(), firstName: "cristian", lastName: "felipe")
    try await user2.upsert()
    try await user2
        .update(.firstName("hello"))
        .upsert()
    
    try await User.upsert(.init(firstName: "Cristian", lastName: "Rojas"))
    
}


