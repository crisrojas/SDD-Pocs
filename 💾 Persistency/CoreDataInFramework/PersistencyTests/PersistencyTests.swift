//
//  Manager.swift
//  ThingsTests
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2023.
//

import XCTest
@testable import Persistency

final class ManagerTest: XCTestCase {
    
    var context: NSManagedObjectContext!
    var manager: CoreDataManager!
    
    override func setUp() {
        context = PersistenceController(inMemory: true).context()
        manager = CoreDataManager(context: context)
    }
    
    override func tearDown() {
        context = nil
        manager = nil
    }
    
   
    func test_create_item() async throws {
        let id = UUID()
        try await manager.create_item(with: id)
        
        var items = try await manager.read()
        XCTAssertFalse(items.isEmpty)
        
        let item = try await manager.read(id: id)
        XCTAssertNotNil(item)
        
        try await manager.delete(id: item!.id!)
        items = try await manager.read()
        XCTAssert(items.isEmpty)
    }
}

