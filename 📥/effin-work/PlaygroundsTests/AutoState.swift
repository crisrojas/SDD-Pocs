//
//  AutoState.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 11/12/23.
//

import Foundation

/// Core ideas:
/// have an object that stores state
/// have that object to be reusable on every project
/// have that object to receive an array of types and store a cache that act as a db for each
/// wanted api:
/// let store = Store(entities: [ToDo.Self, Project.Self, Area.Self]
/// store.upsert(ToDo(name: "do laundry"))

struct ToDo: Persistable {
    let id: UUID
    var name: String
}

fileprivate var store = AutoStore(path: "debug")

import SwiftUI
struct App {
    
    var body: some View {
        VStack {
            ToDoList(todos: store.read())
        }
    }
    
    struct ToDoList: View {
        let todos: [ToDo]
        var body: some View {
            List(todos) { item in
                NavigationLink {
                    ToDoDetail(
                        todo: item,
                        save: store.upsert(_:)
                    )
                } label: {
                    Text(item.name)
                }

            }
        }
    }
    
    struct ToDoDetail: View {
        @State var todo: ToDo
        let save: (ToDo) -> Void
        var body: some View {
            TextField("edit", text: $todo.name)
                .onSubmit {
                    save(todo)
                }
        }
    }
}

struct AnyPersistable: Persistable {
   private let _id: () -> UUID
   private let _encode: (Encoder) throws -> Void
   private let _decode: (Decoder) throws -> Void

   var id: UUID { _id() }

   init<Base: Persistable>(_ base: Base) {
       _id = { base.id as! UUID }
       _encode = { try base.encode(to: $0) }
       _decode = { try type(of: base).init(from: $0) }
   }

   func encode(to encoder: Encoder) throws {
       try _encode(encoder)
   }

   init(from decoder: Decoder) throws {
       fatalError("init(from:) has not been implemented")
   }
}


typealias Persistable = Identifiable & Codable
final class AutoStore: ObservableObject {
    
    typealias Cache = [String:any Persistable]
    let path: String
    
    init(path: String) {
        self.path = path
    }
    
    lazy var db = read() {
        didSet { persist() }
    }

    func read() -> [String: Cache] {
      var cache: [String: Cache] = [:]
      for type in Mirror(reflecting: Persistable.self).children {
          let typeName = String(describing: type.value)
          if let data = try? Data(contentsOf: fileURL(path: "\(typeName)-\(path)-db.json")),
             let items = try? JSONDecoder().decode([AnyPersistable].self, from: data) {
              cache[typeName] = Dictionary(uniqueKeysWithValues: items.map { ($0.id.description, $0) })
          }
      }
      return cache
    }


    func fileURL(path: String) -> URL {
       let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
       return documentsDirectory.appendingPathComponent(path)
    }
    
    func persist() {
        db.forEach { key, value in
            let type = String(describing: type(of: value))
            if let unboxed = value as? (any Persistable) {
                if let jsonData = try? JSONEncoder().encode(unboxed) {
                    try? FileJsonCruder.write(jsonData, to: "\(type)-\(path)-db.json")
                }
            }
        }
    }

    
    func read<T: Persistable>() -> [T] {
        let t = String(describing: T.self)
        return db[t]?.values.compactMap { $0 as? T } ?? []
    }
    
    func read<T: Persistable>(id: T.ID) -> T? {
        let t = String(describing: T.self)
        let item = db[t]?[String(describing: id)]
        return item as? T
    }
    
    func upsert(_ item: any Persistable) {
        let type = String(describing: type(of: item))
        let id = String(describing: item.id)
        if let _ = db[type] {
            db[type]?[id] = item
        } else {
            let dict = [id:item]
            db[type] = dict
        }
    }
    
    func delete(_ item: any Persistable) {
        let type = String(describing: type(of: item))
        let id = String(describing: item.id)
        db[type]?[id] = nil
    }
}


import XCTest
final class StoreTestsBis: XCTestCase {
    
    struct ToDo: Persistable, Equatable {
        let id = UUID()
        var name: String
    }
    
    func makeSUT() -> AutoStore {
        .init(path: "tests")
    }
    
    func test_create() {
        let store = makeSUT()
        let todo = ToDo(name: "test")
        store.upsert(todo)
        XCTAssertEqual((store.db["ToDo"]?[todo.id.description] as? ToDo)?.name, "test")
    }
    
    func test_read() {
        let store = makeSUT()
        let todo = ToDo(name: "test")
        store.upsert(todo)
        let todos: [ToDo] = store.read()
        XCTAssertEqual(todos, [todo])
    }
    
    func test_read_item() {
        let store = makeSUT()
        let todo = ToDo(name: "test")
        store.upsert(todo)
        let fetched: ToDo? = store.read(id: todo.id)
        XCTAssertEqual(todo, fetched)
    }
    
    func test_update() {
        let store = makeSUT()
        var todo = ToDo(name: "test")
        store.upsert(todo)
        todo.name = "Hello world"
        store.upsert(todo)
        XCTAssertEqual((store.db["ToDo"]?[todo.id.description] as? ToDo)?.name, "Hello world")
    }
    
    func test_delete() {
        let store = makeSUT()
        var todo = ToDo(name: "test")
        store.upsert(todo)
        store.delete(todo)
        XCTAssertNil((store.db["ToDo"]?[todo.id.description] as? ToDo))
    }
}
