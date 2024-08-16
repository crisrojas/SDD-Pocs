//
//  _persistency.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 12/04/2024.
//

import Foundation


enum FileBase {
    static let favorites = JSON.Persisted("favorites")
    static let ratings   = JSON.Persisted("ratings")
}

extension JSON {
    final class Persisted: ObservableObject {
        
        // Prevents unneeded write on init
        var isInitializing = true
        @Published var data = JSON.array() {
            didSet { if !isInitializing { persist() } }
        }
        
        var items: [JSON] {data.array}
        
        let path: String
        init(_ path: String) {
            self.path = path + ".txt"
            data = read()
            isInitializing = false
        }
        
        func contains(_ itemId: String) -> Bool {read(id: itemId) != nil}
        
        func read() -> JSON {
            do {
                let data = try Data(contentsOf: fileURL())
                return try JSON(data: data)
            } catch {
                dp("Error reading file: \(error)")
                return .array([])
            }
        }
        
        func read(id: String) -> JSON? {data.array.first(where: {$0.id == id})}
        
        func toggle(_ item: JSON) {
            if contains(item.id) {
                delete(item)
            } else {
                add(item)
            }
        }
        
        func upsert(_ item: JSON) {
            if let _ = data.array.first(where: { $0.id == item.id }) {
                let new = data.array.filter { $0.id != item.id } + [item]
                data = .array(new)
            } else {
                add(item)
            }
        }
        
        private func add(_ item: JSON) {
            let new = data.array + [item]
            data = .array(new)
        }
        
        func delete(_ item: JSON) {
            var array = data.array
            if let index = array.firstIndex(where: {$0.id == item.id}) {
                array.remove(at: index)
            }
            data = .array(array)
        }
        
        func persist() {
            guard let data = try? data.encode() else {
                dp("Failed to encode MagicJSON")
                return
            }
            
            do {
                try data.write(to: fileURL())
            } catch {
                dp("Error writing file: \(error)")
            }
        }
        
        func destroy() {data = .array()}
        
        func fileURL() throws -> URL {
            try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent(path)
        }
    }
}
