//
//  FilePersistable.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 20/11/23.
//

import Foundation

/// A protocol that allows a type to persist itself and perform CRUD operations over a serlialized disk store
protocol FilePersistable: Codable, Identifiable {
    static var path: String {get set}
}

fileprivate var fr_jsonEncoder = JSONEncoder()
fileprivate var fr_jsonDecoder = JSONDecoder()
fileprivate var fr_fileManager = FileManager()

extension FilePersistable {
    static var jsonDecoder: JSONDecoder {fr_jsonDecoder}
    static var jsonEncoder: JSONEncoder {fr_jsonEncoder}
    static var fileManager: FileManager {fr_fileManager}
    static func read() throws -> [Self] {try Self.read(Self.path)}
    func upsert() throws {
        let saved   = try Self.read(Self.path)
        let updated = saved.filter { $0.id == id } + [self]
        #if DEBUG
        Self.jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try Self.jsonEncoder.encode(updated)
        try data.write(to: Self.fileURL(path: Self.path))
    }
    
    static func read(id: Self.ID) throws -> Self? {
        try Self.read().first(where: {$0.id == id})
    }
    
    static func read(_ path: String) throws -> [Self] {
        try jsonDecoder.decode([Self].self, from: try Data(contentsOf: fileURL(path: path)))
    }
    
    static func destroy() throws {
        try fileManager.removeItem(atPath: fileURL(path: Self.path).path)
    }
    
    static func fileURL(path: String) throws -> URL {
        try fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
    }
}

struct FP_User: FilePersistable, KeyPathMutable {
    static var path: String = "user.json"
    
    let id: UUID
    var name: String
}

fileprivate func test_fp_() {
    var user = FP_User(id: .init(), name: "hello")
    FP_User.path = "test-user.json"
    let _ = try? FP_User.read()
    let _ = try? FP_User.read(id: .init())
    let _ = try? FP_User.destroy()
    
    try? user.upsert()
    
    try? user
        .updated(\.name, with: "cristian felipe")
        .upsert()
        
}
