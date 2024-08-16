//
//  NetworkingTests.swift
//  NetworkingTests
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import XCTest
import Networking

final class BackentTests: XCTestCase {
    
    var sut: Backend!
    
    override func setUp() {
        sut = .init(id: "tests")
        sut.startInterceptingRequests()
    }
    
    override func tearDown() async throws {
        try sut.destroy()
        sut = nil
    }
    
    func test_count_is_persisted_on_disk_when_added_to_counts_dict() throws {
        
        let newItem = Count(name: "Fucks given", value: 0)
        
        sut.counters.upsert(newItem)
        
        let count: [String: Count]? = sut.counters.readDb()
        
        let persistedData = try XCTUnwrap(count)
        let item = persistedData[newItem.id.description]
        XCTAssertEqual(item?.name, "Fucks given")
        XCTAssertEqual(item?.value, 0)
    }
    
    func test_instances_dont_share_data() throws {
        let newItem = Count(name: "Fucks given", value: 0)
        sut.counters.upsert(newItem)
        
        let otherBEDiskStore = Backend(id: "other-instance-could-be-production").counters.readDb()
        XCTAssert(otherBEDiskStore.isEmpty)
    }
    
    func test_backend_interecepts_counts_get_request_and_sends_them() async throws {
        sut.counters.upsert(.init(name: "Poops of the day", value: 42))
        let (data, _) = try await URLSession.shared.data(from: "https://backend.test/api/counters")
        let decoded = try JSONDecoder().decode(Wrapper<[Count]>.self, from: data)
        XCTAssertEqual(decoded.data.first?.name, "Poops of the day")
    }
    
    func test_backend_send_count_with_id() async throws {
        let newItem = Count(name: "Poops of the day", value: 42)
        sut.counters.upsert(newItem)
        let (data, _) = try await URLSession.shared.data(from: "https://backend.test/api/counters/\(newItem.id)")
        let decoded = try JSONDecoder().decode(Wrapper<Count>.self, from: data)
        XCTAssertEqual(decoded.data.name, "Poops of the day")
        XCTAssertEqual(decoded.data.value, 42)
    }
    
    func test_backend_posts_new_count() async throws {
        var request = URLRequest(url: "https://backend.test/api/counters")
        request.httpBody = """
        {
            "name": "Testing post",
            "value": 32
        }
        """.asData
        request.httpMethod = "POST"
        let (_, _) = try await URLSession.shared.data(for: request)
        
        let persisted = sut.counters.readDb().first?.value
        XCTAssertEqual(persisted?.name, "Testing post")
    }
}
