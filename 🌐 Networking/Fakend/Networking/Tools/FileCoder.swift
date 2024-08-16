//
//  FileCoder.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import Foundation

protocol FileCoder {}
extension FileCoder {
    // MARK: - FileManager
    func write<C: Codable>(_ codable: C, to path: String) throws {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(codable)
        try data.write(to: fileURL(path: path))
    }
    
    func read<C: Codable>(_ path: String) -> C? {
        do {
            return try jsonDecoder
                .decode(C.self, from: try Data(contentsOf: fileURL(path: path)))
        } catch {
            print("Failure when trying to read state:")
            print(error)
            return nil
        }
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
