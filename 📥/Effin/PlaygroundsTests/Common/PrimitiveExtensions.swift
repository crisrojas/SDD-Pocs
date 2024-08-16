//
//  Extensions.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 20/11/23.
//

import Foundation

/// Idiomatic primitives
/// Maybe String shares its property isEmpty with arrays through protocol conformance, it would be more useful extending the protocol
extension String {
    var isNotEmpty: Bool { !isEmpty }
}

extension Array {
    var isNotEmpty: Bool { !isEmpty }
}

extension Set {
    var isNotEmpty: Bool { !isEmpty }
}

extension Int {
    /// Maybe we could make this automatic too on double, uint, etc...
    var asString: String { description  }
    var asDouble: Double { Double(self) }
}

extension Double {
    var asString: String { description }
    var asInt: Int { Int(self) }
}

extension Optional {
    var isNil: Bool    { self == nil }
    var isNotNil: Bool { self != nil }
}

