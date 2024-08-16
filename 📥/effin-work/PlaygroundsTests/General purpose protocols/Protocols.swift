//
//  Protocols.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 18/11/23.
//

import Foundation


/// Conformers should return a copy of themselves with a mutated id
protocol Forkable: Identifiable {func fork() -> Self}
//Cannot assign to property: 'id' is a get-only property
//extension Forkable where Self.ID == UUID {
//    func fork() -> Self {
//        var copy = self
//        copy.id = .init()
//        return copy
//    }
//}
/// An object that can be constructed with an empty constructor
protocol Initializable { init() }
