//
//  Database.swift
//  Core
//
//  Created by Cristian Felipe Patiño Rojas on 22/12/2023.
//

import Foundation

public protocol Persistable: Identifiable, Codable {
    var id: UUID {get}
}

extension Persistable {
    static var entityName: String { String(describing: Self.self) }
}



public class Database: ObservableObject {
    @Published var tables: [Table] = []
    var path: String
    let directory: FileManager.SearchPathDirectory
    let manager = FileManager.default
    
    public init(path: String, directory: FileManager.SearchPathDirectory = .applicationSupportDirectory) {
        self.path = path
        self.directory = directory
        try? createFolder(on: directory)
        tables = retrieveFromDirectory() // @todo: don't like making this inside init
    }
    
    func createFolder(on directory: FileManager.SearchPathDirectory) throws {
        let desktopURL = try FileManager.default.url(
            for: directory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        
        let folderURL = desktopURL.appendingPathComponent(path, isDirectory: true)
        
        try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
    }
    
    func makeTable(name: String) -> Table {
        .init(parentFolder: path, name: name, directory: directory)
    }
    
    func retrieveFromDirectory() -> [Table] {
        do {
            let directoryURL = try fileURL()
            let files = try FileManager.default.contentsOfDirectory(atPath: directoryURL.path)
            
            return files
                .filter { $0.hasSuffix(".json") }
                .map { fileName in
                    let tableName = fileName.replacingOccurrences(of: ".json", with: "")
                    return makeTable(name: tableName)
                }
        } catch {
            print("Error retrieving files from directory: \(error)")
            return []
        }
    }
    
    public func destroy() throws {
        let url = try fileURL()
        try manager.removeItem(at: url)
    }
    
    public func read<T: Persistable>(id: UUID) -> T? {
        guard let table = tables.first(where: { $0.name == T.entityName }) else { return nil }
        guard let data = table.storage[id] else { return nil }
        return try? table.decoder.decode(T.self, from: data)
    }

    public func read<T: Persistable>() -> [T] {
        if let table = tables.first(where: { $0.name == T.entityName }) {
            return table.read()
        } else {
            let table = makeTable(name: T.entityName)
            tables.append(table)
            return table.read()
        }
    }
    
    public func upsert<T: Persistable>(_ item: T) throws {
        if let table = tables.first(where: { $0.name == T.entityName }) {
            try table.upsert(item)
        } else {
            let table = makeTable(name: T.entityName)
            tables.append(table)
            try table.upsert(item)
        }
        self.objectWillChange.send()
    }

    public func delete<T: Persistable>(_ item: T) {
        if let table = tables.first(where: { $0.name == T.entityName }) {
            table.delete(item)
        } else {
            let table = makeTable(name: T.entityName)
            tables.append(table)
            table.delete(item)
        }
        self.objectWillChange.send()
    }
    
    @discardableResult
    func deleteAll<T: Persistable>() -> [T] {
        if let table = tables.first(where: { $0.name == T.entityName }) {
            let deleted: [T] = table.deleteAll()
            self.objectWillChange.send()
            return deleted
        }
        return []
    }
    
    func fileURL() throws -> URL {
        try FileManager.default
            .url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
    }
}


public class Table {
    fileprivate(set) lazy var storage: [UUID: Data] = readFile() {didSet{try?persist()}}
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let manager = FileManager.default
    
    let name: String
    let ext: String
    lazy var path: String = name + ext
    let parentFolder: String
    
    let directory: FileManager.SearchPathDirectory
    
    public init(parentFolder: String, name: String, ext: String = ".json", directory: FileManager.SearchPathDirectory) {
        self.parentFolder = parentFolder
        self.ext = ext
        self.name = name
        self.directory = directory
    }
}

// MARK: - API
extension Table {
    public func read<T: Persistable>(id: UUID) -> T? {
        guard let data = storage[id] else { return nil }
        return try? decoder.decode(T.self, from: data)
    }

    public func read<T: Persistable>() -> [T] {
        storage.compactMap { (_, data) in
            try? decoder.decode(T.self, from: data)
        }
    }
    
    public func upsert<T: Persistable>(_ item: T) throws {
        let data = try encoder.encode(item)
        storage[item.id] = data
    }

    public func delete<T: Persistable>(_ item: T) {
        storage[item.id] = nil
    }
    
    @discardableResult
    public func deleteAll<T: Persistable>() -> [T] {
        (read() as [T]).forEach {
            storage[$0.id] = nil
        }
        return []
    }
}

// MARK: - File handling

extension Table {
    
    func persist() throws {
        let data = try encoder.encode(storage)
        let url = try fileURL(path: path)
        // Verificar si el archivo existe antes de intentar escribir
        if FileManager.default.fileExists(atPath: url.path) {
            try data.write(to: fileURL(path: path))
        } else {
            // Si el archivo no existe, intenta crear el directorio y luego escribe el archivo
            try FileManager.default.createDirectory(
                at: fileURL(path: path).deletingLastPathComponent(),
                withIntermediateDirectories: true,
                attributes: nil
            )
            try data.write(to: fileURL(path: path))
        }
    }
    
    func readFile() -> [UUID: Data] {
        (try? decoder.decode([UUID:Data].self, from: try Data(contentsOf: fileURL(path: path)))) ?? [:]
    }
    
    func fileURL(path: String) throws -> URL {
        try manager
            .url(for: directory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(parentFolder)
            .appendingPathComponent(path)
    }
    
    public func destroy() throws {
        do {
            try manager.removeItem(atPath: fileURL(path: path).path)
        } catch {
            /// Error == 4 means we can destroy because the file doesn't exist.
            /// We want to ignore that case when trying to destroy the db, specially during test teardown
            guard (error as NSError).code != 4 else {
                return
            }
            throw error
        }
    }
}
