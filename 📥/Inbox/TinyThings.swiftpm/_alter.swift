//
//  _keypathmutable.swift
//  UIPlayground
//
//  Created by Cristian Felipe Patiño Rojas on 02/04/2024.
//

import Foundation


//
//  KeyPath mutation.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 19/11/23.
//
// #functional

import SwiftUI

func * <T>(lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}
