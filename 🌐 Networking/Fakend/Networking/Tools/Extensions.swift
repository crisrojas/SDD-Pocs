//
//  Extensions.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import Foundation

/// Request body data objects get transparently converted into streaming-style bodies by the URL loading system before they reach you
extension Data {
    init(reading input: InputStream) throws {
        self.init()
        input.open()
        defer { input.close() }
        
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }
        
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: bufferSize)
            if read < 0 {
                // Se produjo un error en el Stream
                throw input.streamError!
            } else if read == 0 {
                // EOF
                break
            }
            self.append(buffer, count: read)
        }
    }
}

extension URLRequest {
    public init(url: String) {
        self.init(url: URL(string: url)!)
    }
}

extension URLSession {
    public func data(from url: String) async throws -> (Data, URLResponse) {
        try await data(from: URL(string: url)!)
    }
}

extension Encodable {
    func encoded() -> Data {try! jsonEncoder.encode(self)}
}
