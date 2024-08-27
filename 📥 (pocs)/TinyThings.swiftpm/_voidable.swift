//
//  _voidable.swift
//  UIPlayground
//
//  Created by Cristian Felipe Patiño Rojas on 02/04/2024.
//

import Foundation

enum _Async<T> {
    enum Throws {
        typealias Void = (T) async throws -> Swift.Void
        
        typealias Same  =  (Self) async throws -> Self
        // Swift Primitives
        typealias String = (Self) async throws -> Swift.String
        typealias Int    = (Self) async throws -> Swift.Int
        typealias Double = (Self) async throws -> Swift.Double
        typealias Bool   = (Self) async throws -> Swift.Bool
        
        // Custom type
        typealias Returns<T> = (T) async throws -> T
    }
    
    typealias Void = (T) async -> Swift.Void
    
    typealias Same  =  (Self) async -> Self
    // Swift Primitives
    typealias String = (Self) async -> Swift.String
    typealias Int    = (Self) async -> Swift.Int
    typealias Double = (Self) async -> Swift.Double
    typealias Bool   = (Self) async -> Swift.Bool
    
    // Custom type
    typealias Returns<T> = (T) async -> T
}

enum _Throws<T> {
    typealias Void = (T) throws -> Swift.Void
    
    typealias Same  =  (Self) throws -> Self
    // Swift Primitives
    typealias String = (Self) throws -> Swift.String
    typealias Int    = (Self) throws -> Swift.Int
    typealias Double = (Self) throws -> Swift.Double
    typealias Bool   = (Self) throws -> Swift.Bool
    
    // Custom type
    typealias Returns<T> = (T) throws -> T
}

protocol Voidable {}

extension Voidable {
    typealias Void = (Self) -> Swift.Void
    typealias Async = _Async<Self>
    typealias Throws = _Throws<Self>
    
    typealias Same  =  (Self) -> Self
    // Swift Primitives
    typealias String = (Self) -> Swift.String
    typealias Int    = (Self) -> Swift.Int
    typealias Double = (Self) -> Swift.Double
    typealias Bool   = (Self) -> Swift.Bool
    
    // Custom type
    typealias Returns<T> = (Self) -> T
}

extension Int: Voidable {}
extension Double: Voidable {}
extension String: Voidable {}
extension Bool: Voidable {}
extension UUID: Voidable {}
