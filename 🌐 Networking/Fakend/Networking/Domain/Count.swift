//
//  Count.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import Foundation

public struct Count {
    
    public let id: UUID
    public let name: String
    public let value: Int
    
    public init(name: String, value: Int) {
        id = .init()
        self.name = name
        self.value = value
    }
    
    fileprivate init(id: UUID, name: String, value: Int) {
        self.id = id
        self.name = name
        self.value = value
    }
}

// MARK: - UpdateEncodable conformance
extension Count {
    public typealias PUT  = Self
    
    public struct POST: Codable {
        let name: String
        let value: Int
        
        public init(name: String, value: Int) {
            self.name = name
            self.value = value
        }
    }
    
    public struct PATCH: Codable {
        public init(name: String? = nil, value: Int? = nil) {
            self.name = name
            self.value = value
        }
        
        let name: String?
        let value: Int?
        
    }
}

extension Count: ResourceType {
    
    public func from(put: PUT) -> Self {
        .init(id: id, name: put.name, value: put.value)
    }
    
    public init(post: POST) {
        id = UUID()
        name = post.name
        value = post.value
    }
    
    public func from(patch: PATCH) -> Self {
        .init(
            id: id,
            name: patch.name ?? name,
            value: patch.value ?? value
        )
    }
}

