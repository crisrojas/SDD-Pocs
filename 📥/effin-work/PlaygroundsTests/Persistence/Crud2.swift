//
//  Crud2.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 18/11/23.
//

import Foundation

typealias Crudable = Mappable & Identifiable

extension User {
    static let localCrud = Crud<User>(
        create: {_ in},
        read: { [] },
        readid: {_ in nil},
        update: {_ in},
        delete: {_ in}
    )
    
    static let remoteCrud = Crud<User>(
        create: {_ in},
        read: { [] },
        readid: {_ in nil},
        update: {_ in},
        delete: {_ in}
    )
    
    static var worker = UserWorker(
        remoteCRUD: User.remoteCrud,
        localCRUD: User.localCrud
    )
}

final class UserWorker: CrudWorker {
    var remoteCRUD: Crud<User>
    var localCRUD: Crud<User>
    
    init(remoteCRUD: Crud<User>, localCRUD: Crud<User>) {
        self.remoteCRUD = remoteCRUD
        self.localCRUD = localCRUD
    }
}

func worker() async {
   try? await User.worker.delete(UUID())
}

protocol CrudWorker {
    associatedtype ModelType: Crudable
    var isReachable: Bool {get}
    var remoteCRUD: Crud<ModelType> {get set}
    var localCRUD : Crud<ModelType> {get set}
}

extension CrudWorker {
    var isReachable: Bool { true }
    func create(_ element: ModelType) async throws {
        if isReachable {
            try await remoteCRUD.create(element)
            try await localCRUD.create(element)
        } else {
            try await localCRUD.create(element)
        }
    }
    
    // ¿No aplica ?
    func read() async throws -> [ModelType] {
        if isReachable { return try await remoteCRUD.read() }
        else { return try await localCRUD.read() }
    }
    
    // ¿No aplica?
    func readid(id: ModelType.ID) async throws -> ModelType? {
        if isReachable { return try await remoteCRUD.readid(id) }
        else { return try await localCRUD.readid(id) }
    }
    
    
    func update(_ element: ModelType) async throws {
        if isReachable {
            try await remoteCRUD.update(element)
            try await localCRUD.update(element)
        } else {
            try await localCRUD.update(element)
        }
    }
    
    func delete(_ element: ModelType.ID) async throws {
        if isReachable {
            try await remoteCRUD.delete(element)
            try await localCRUD.delete(element)
        } else {
            try await localCRUD.delete(element)
        }
    }
}


protocol CrudProtocol {
    associatedtype T: Identifiable
    var create: (T) async throws -> Void { get }
    var read  : ( ) async throws -> [T] { get }
    var readid: (T.ID) async throws -> T? { get }
    var update: (T) async throws -> Void { get }
    var delete: (T.ID) async throws -> Void { get }
}

final class Crud<T: Crudable>: CrudProtocol {
    let create: (T) async throws -> Void
    let read  : ( ) async throws -> [T]
    let readid: (T.ID) async throws -> T?
    let update: (T) async throws -> Void
    let delete: (T.ID) async throws -> Void
  
    init(create: @escaping (T) -> Void, read: @escaping () -> [T], readid: @escaping (T.ID) -> T?, update: @escaping (T) -> Void, delete: @escaping (T.ID) -> Void) {
        self.create = create
        self.read = read
        self.readid = readid
        self.update = update
        self.delete = delete
    }
}
