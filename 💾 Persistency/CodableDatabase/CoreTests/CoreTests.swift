//
//  Database.swift
//  PlaygroundsTests
//
//  Created by Cristian Felipe Patiño Rojas on 13/12/2023.
//

import Foundation
import CustomDump
import Core

import XCTest


final class DatabaseTests: XCTestCase {
    
    var db: Database!
    
    override func setUp() async throws {
        db = .init(path: "tests", directory: .applicationSupportDirectory)
    }
    
    override func tearDownWithError() throws {
        try db.destroy()
    }
    
    func test_() throws {
        let first: Todo? = db.read().first
        XCTAssertNil(first)
    }
    
    func test_create_and_readId() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        let item: Todo? = db.read(id: todo.id)
        XCTAssertEqual(item, todo)
    }
    
    func test_read() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        let items: [Todo] = db.read()
        XCTAssertNoDifference(items, [todo])
    }
    
    func test_update() throws {
        var todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        var item: Todo? = db.read(id: todo.id)
        XCTAssertEqual(item?.name, "Make coffee")
        todo.name = "Make 20 coffees"
        try db.upsert(todo)
        item = db.read(id: todo.id)
        XCTAssertEqual(item?.name, "Make 20 coffees")
    }
    
    func test_delete() throws {
        let todo = Todo(name: "Make coffee")
        try db.upsert(todo)
        db.delete(todo)
        let item: Todo? = db.read(id: todo.id)
        XCTAssertNil(item)
    }
}

struct Todo: Persistable, Equatable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}


final class TableTests: XCTestCase {
  
    var table: Table!
    
    override func setUp() {
        table = .init(parentFolder: "tests-folder", name: "Todo", directory: .desktopDirectory)
    }
    
    override func tearDownWithError() throws {
        let url = try FileManager.default
            .url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("tests-folder")
        
        try FileManager.default.removeItem(at: url)
    }
    
    func test_create() throws {
        let todo = Todo(name: "Make coffee")
        try table.upsert(todo)
        let item: Todo? = table.read(id: todo.id)
        XCTAssertEqual(item, todo)
    }
    
    func test_read() throws {
        let todo = Todo(name: "Make coffee")
        try table.upsert(todo)
        let items: [Todo] = table.read()
        XCTAssertEqual(items, [todo])
    }
    
    func test_readItem() throws {
        let todo = Todo(name: "Make coffee")
        try table.upsert(todo)
        let item: Todo? = table.read(id: todo.id)
        XCTAssertEqual(item, todo)
    }
    
    func test_update() throws {
        var todo = Todo(name: "Make coffee")
        try table.upsert(todo)
        var item: Todo? = table.read(id: todo.id)
        XCTAssertEqual(item?.name, "Make coffee")
        todo.name = "Make 20 coffees"
        try table.upsert(todo)
        item = table.read(id: todo.id)
        XCTAssertEqual(item?.name, "Make 20 coffees")
    }
    
    func test_delete() throws {
        let todo = Todo(name: "Make coffee")
        try table.upsert(todo)
        table.delete(todo)
        let item: Todo? = table.read(id: todo.id)
        XCTAssertNil(item)
    }
    
    func test_delete_all() throws {
        let todo = Todo(name: "Make coffee")
        try table.upsert(todo)
        let _: [Todo] = table.deleteAll()
        let item: Todo? = table.read(id: todo.id)
        XCTAssertNil(item)
    }
}




//final class DatabaseTestsBis: XCTestCase {
//    var db: Database!
//
//    override func setUp() async throws {
//        db = .init(path: self.className, directory: .desktopDirectory)
//    }
//
////    func test_create() throws {
////        let todo = Todo(name: "Make some coffee")
////        try db.upsert(todo)
////        let item: Todo? = db.read(id: todo.id)
////        XCTAssertEqual(item, todo)
////    }
//
//    func test_read() {
//        let item: Todo? = db.read().first
//        XCTAssertNotNil(item)
//    }
//}
