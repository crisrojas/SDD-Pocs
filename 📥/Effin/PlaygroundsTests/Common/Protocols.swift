//
//  Protocols.swift
//  Effin
//
//  Created by Cristian Patiño Rojas on 18/11/23.
//

import Foundation


/// Conformers should return a copy of themselves with a mutated id
protocol Forkable: Identifiable {func fork() -> Self}
/// An object that can be constructed with an empty constructor
protocol Initializable { init() }
