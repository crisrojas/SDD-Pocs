//
//  BackendResourceTests.swift
//  NetworkingTests
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import XCTest
import Networking

fileprivate var jsonDecoder = JSONDecoder()


final class BackendResourceTests: XCTestCase {
    
    var sut: BackendResource<ToDo>!
    
    override func setUp() {
        sut = .init(
            parentId: "debug",
            baseURL: "https://backend.com/api",
            path: "todos"
        )
    }
    
    override func tearDown() async throws {
        try sut.destroyDb()
        sut = nil
    }
    
    
    func test_destroyDb_doesnt_throw_error_if_file_doesnt_exist() throws {
       XCTAssertNoThrow (try sut.destroyDb())
    }
    
    func test_added_items_are_persisted_to_database()  {
        sut.upsert(.init(title: "Take a nap"))
        let db = sut.readDb()
        XCTAssertEqual(db.first?.value.title, "Take a nap")
    }
    
    func test_deleted_item_is_removed_from_database() {
        let item = ToDo(title: "Take a nap")
        sut.upsert(item)
        sut.delete(item)
        let db = sut.readDb()
        XCTAssertEqual(db, [:])
    }
    
    func test_GET_all() throws {
        let item = ToDo(title: "Test todo")
        sut.upsert(item)
        
        var request = URLRequest(url: "http://tests.com/todos")
        request.httpMethod = "GET"
        
        let (data, _) = sut.handle(request)
        let decoded = try jsonDecoder.decode(Wrapper<[ToDo]>.self, from: data)
        XCTAssertEqual(decoded.data, [item])
    }
    
    func test_GET_with_id() throws {
        let item = ToDo(title: "Test todo")
        sut.upsert(item)
        
        var request = URLRequest(url: "http://tests.com/todos/\(item.id)")
        request.httpMethod = "GET"
        
        let (data, _) = sut.handle(request)
        let decoded = try jsonDecoder.decode(Wrapper<ToDo>.self, from: data)
        XCTAssertEqual(decoded.data, item)
    }
    
    func test_POST() {
        var request = URLRequest(url: "http://test.com/todos")
        request.httpMethod = "POST"
        
        request.httpBody = """
        {
            "title": "My test task",
            "isChecked": false
        }
        """.asData
        
        let (_, _) = sut.handle(request)
        
        let db = sut.readDb()
        
        XCTAssertEqual(db.first?.value.title, "My test task")
    }
    
    func test_PUT() {
        let item = ToDo(title: "Test todo")
        sut.upsert(item)
        
        var request = URLRequest(url: "http://test.com/todos/\(item.id)")
        request.httpMethod = "PUT"
        
        request.httpBody = """
        { "isChecked": true }
        """.asData
        
        let (_, _) = sut.handle(request)
        
        let db = sut.readDb()
        let dbItem = db[item.id.description]
        
        XCTAssertEqual(dbItem?.title, nil)
        XCTAssertEqual(dbItem?.isChecked, true)
    }
    
    func test_PATCH() {
        let item = ToDo(title: "Test todo")
        sut.upsert(item)
        
        var request = URLRequest(url: "http://test.com/todos/\(item.id)")
        request.httpMethod = "PATCH"
        
        request.httpBody = """
        { "isChecked": true }
        """.asData
        
        let (_, _) = sut.handle(request)
        
        let db = sut.readDb()
        let dbItem = db[item.id.description]
        
        XCTAssertEqual(dbItem?.title, "Test todo")
        XCTAssertEqual(dbItem?.isChecked, true)
    }
    
    func test_DELETE() {
        let item = ToDo(title: "Test todo")
        sut.upsert(item)
        
        var request = URLRequest(url: "http://test.com/todos/\(item.id)")
        request.httpMethod = "DELETE"
        
        let (_, _) = sut.handle(request)
        
        let db = sut.readDb()
        
        XCTAssertEqual(db, [:])
    }
}


extension String {
    var asData: Data {data(using: .utf8)!}
}


// MARK: - Test entity
struct ToDo: Equatable {
    let id: UUID
    let title: String?
    let isChecked: Bool
    
    init(id: UUID = .init(), title: String?, isChecked: Bool = false) {
        self.id = id
        self.title = title
        self.isChecked = isChecked
    }
}

extension ToDo {
    struct PUT_POST: Decodable {
        var title: String?
        var isChecked: Bool
    }
    
    typealias PUT  = PUT_POST
    typealias POST = PUT_POST
    
    struct PATCH: Decodable {
        var title: String?
        var isChecked: Bool?
    }
}

extension ToDo: ResourceType {
    func from(put: PUT) -> Self {
        .init(
            id: id,
            title: put.title,
            isChecked: put.isChecked
        )
    }
    
    func from(patch: PATCH) -> Self {
        .init(
            id: id,
            title: patch.title ?? title,
            isChecked: patch.isChecked ?? isChecked
        )
    }
    
    init(post: POST) {
        id = UUID()
        title = post.title
        isChecked = post.isChecked
    }
}
