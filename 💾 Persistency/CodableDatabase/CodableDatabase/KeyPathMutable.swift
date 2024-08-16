//
//  KeyPathMutable.swift
//  Core
//
//  Created by Cristian Felipe Patiño Rojas on 22/12/2023.
//

import Foundation

// MARK: - Mappable
protocol Mappable {}
extension Mappable {
    func map(transform: (inout Self) -> Void) -> Self {
        var new = self
        transform(&new)
        return new
    }
}



protocol KeyPathMutable {}
extension KeyPathMutable {
    /// A mutating func as follows wouldn't be useful
    /// mutating func update<V>(_ kp: WritableKeyPath<Self, V>, with value: V)
    ///
    /// It would be redundanrt:
    ///
    /// person.update(\.name, 30)
    /// vs
    /// person.name = 30
    
    func updated<V>(_ kp: WritableKeyPath<Self, V>, with value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func makeCopy<V>(withUpdated kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    
    func with<V>(_ kp: WritableKeyPath<Self, V>, changedTo value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func with<V>(_ kp: WritableKeyPath<Self, V>, equalTo value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func with<V>(_ kp: WritableKeyPath<Self, V>, updatedTo value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func injecting<V>(_ kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func inject<V>(_ kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
}
