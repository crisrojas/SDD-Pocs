//
//  FileCoder.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 20/11/23.
//

import Foundation
fileprivate var _jsonDecoder: JSONDecoder { .init() }
fileprivate var _jsonEncoder: JSONEncoder { .init() }

enum FileJsonCruder: FileJsonCrudable {}
protocol FileJsonCrudable {}
extension FileJsonCrudable {
    static var jsonDecoder: JSONDecoder { _jsonDecoder }
    static var jsonEncoder: JSONEncoder { _jsonEncoder }
    
    // MARK: - FileManager
    static func write<C: Codable>(_ codable: C, to path: String) throws {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(codable)
        try data.write(to: fileURL(path: path))
    }
    
    static func read<C: Codable>(_ path: String) throws -> C? {
      try Self.jsonDecoder.decode(C.self, from: try Data(contentsOf: fileURL(path: path)))
    }
    
    static func destroy(_ path: String) throws {
        try FileManager.default.removeItem(atPath: fileURL(path: path).path)
    }

    static func fileURL(path: String) throws -> URL {
        try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
    }
}

/// Usage:
///
fileprivate let someString: [String]? = try? FileJsonCruder.read("some-path")


/// Not sure if this makes any sense. I'm tired:
protocol FileJsonPersistable: Codable, FileJsonCrudable {}
extension FileJsonPersistable {
//    func write() throws {
//        let data = try Self.jsonEncoder.encode(self)
//        try data.write(to: Self.fileURL(path: String(describing: self)))
//    }
    
    static func read() throws -> [Self]? {
       try read(String(describing: self))
    }
    
    static func destroy() throws {
        try destroy(String(describing: self))
    }
}



protocol FileCodable: Codable {}
extension FileCodable {
    var jsonDecoder: JSONDecoder { .init() }
    var jsonEncoder: JSONEncoder { .init() }
    var fileManager: FileManager { .init() }
    
    // MARK: - FileManager
    func write(to path: String) throws {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(self)
        try data.write(to: fileURL(path: path))
    }
    
    func read(_ path: String) throws -> Self {
      try jsonDecoder.decode(Self.self, from: try Data(contentsOf: fileURL(path: path)))
    }
    
    func destroy(_ path: String) throws {
        try fileManager.removeItem(atPath: fileURL(path: path).path)
    }


    func fileURL(path: String) throws -> URL {
        try fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
    }
}

struct FC_User: FileCodable, Identifiable, Hashable, KeyPathMutable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

protocol FileResource: AnyObject {
    associatedtype ResourceType: Codable, Collection
    var resource: ResourceType {get set}
    var path: String {get set}
}

fileprivate var fr_jsonEncoder = JSONEncoder()
fileprivate var fr_jsonDecoder = JSONDecoder()
fileprivate var fr_fileManager = FileManager()

extension FileResource {
    var jsonDecoder: JSONDecoder {fr_jsonDecoder}
    var jsonEncoder: JSONEncoder {fr_jsonEncoder}
    var fileManager: FileManager {fr_fileManager}
    func load() throws {
        resource = try read(path)
    }
    
    func write() throws {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(resource)
        try data.write(to: fileURL(path: path))
    }
    
    func read(_ path: String) throws -> ResourceType {
        try jsonDecoder.decode(ResourceType.self, from: try Data(contentsOf: fileURL(path: path)))
    }
    
    func destroy(_ path: String) throws {
        try fileManager.removeItem(atPath: fileURL(path: path).path)
    }
    
    func fileURL(path: String) throws -> URL {
        try fileManager
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
    }
}

extension FileResource where ResourceType: Collection, ResourceType.Element: Identifiable {
    typealias Element = ResourceType.Element
    
    func read(id: Element.ID) -> ResourceType.Element? {
        resource.first(where: {$0.id == id})
    }
    
    func upsert(_ element: Element) {
        resource = resource.filter { $0.id != element.id } + [element] as! Self.ResourceType
        try? write()
    }
    
    
    func makeBinding(id: Element.ID) -> Binding<ResourceType.Element> {
        Binding(
            get: {self.read(id: id)!},
            set: {self.upsert($0)   }
        )
    }
}

final class UserFileResource: FileResource, ObservableObject {
    @Published var resource: [FC_User] = [] {didSet {try? write()}}
    var path: String
    
    init(_ path: String = "users.json") {
        self.path = path
    }
}

import SwiftUI
struct FileResourceView: View {
    
    @ObservedObject var users = FileDisk.shared.users
    
    var body: some View {
        if users.resource.isEmpty {
            ProgressView().onAppear { try? users.load() }
        } else {
            List(users.resource, id: \.self) { item in
                Text(item.name)
            }
        }
    }
}

struct FileResourceAddUser: View {
    @ObservedObject var users = FileDisk.shared.users
    @State var name = ""
    var body: some View {
        VStack {
            TextField("name", text: $name)
            Button {
                users.upsert(
                    .init(name: name)
                    .updated(\.name, with: "hello")
                )
            } label: {
                Text("Create user")
            }
        }
    }
}

struct FileResourceEditUser: View {
    
    @ObservedObject var users = FileDisk.shared.users
    let id: UUID
    
    var body: some View {
        TextField("", text: users.makeBinding(id: id).name)
    }
}

final class FileDisk {
    static var shared = FileDisk()
    var users = UserFileResource()
}

func test_() {
    // Dependency injection
    FileDisk.shared.users = UserFileResource("test-users.json")
}
