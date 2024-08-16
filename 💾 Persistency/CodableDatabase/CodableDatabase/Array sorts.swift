//
//  Array sorts.swift
//  CodableDatabase
//
//  Created by Cristian Felipe Patiño Rojas on 30/03/2024.
//

import Foundation



enum SortDirection {
    case asc
    case desc
}

extension Array {
    func sort(_ keyPath: KeyPath<Self.Element, String>..., direction: SortDirection = .asc) -> Self {
        var copy = self
        keyPath.forEach {copy = copy.sort($0)}
        return copy
    }
    
    func sort(_ keyPath: KeyPath<Self.Element, Bool>..., direction: SortDirection = .asc) -> Self {
        var copy = self
        keyPath.forEach {copy = copy.sort($0)}
        return copy
    }
    
    func sort(_ keyPath: KeyPath<Self.Element, String>, direction: SortDirection = .asc) -> Self {
        self.sorted { first, second in
            switch direction {
            case .asc: return  first[keyPath: keyPath] < second[keyPath: keyPath]
            case .desc: return  first[keyPath: keyPath] > second[keyPath: keyPath]
            }
        }
    }
    
    func sort(_ keyPath: KeyPath<Self.Element, Bool>, direction: SortDirection = .asc) -> Self {
        self.sorted { first, second in
            switch direction {
            case .asc: return  first[keyPath: keyPath] && !second[keyPath: keyPath]
            case .desc: return  !first[keyPath: keyPath] && second[keyPath: keyPath]
            }
        }
    }
    
    func sort(_ first: KeyPath<Self.Element, String>,_ second: KeyPath<Self.Element, Bool>) -> Self {
        self
            .sort(first)
            .sort(second)
    }
    
    func sort(_ first: KeyPath<Self.Element, Bool>,_ second: KeyPath<Self.Element, String>) -> Self {
        self
            .sort(second)
            .sort(first)
    }
}


extension Array {
    func sort<T: Comparable>(kp keyPaths: KeyPath<Element, T>..., direction: SortDirection = .asc) -> Self {
        return self.sorted { first, second in
            for keyPath in keyPaths {
                switch direction {
                case .asc:
                    if first[keyPath: keyPath] != second[keyPath: keyPath] {
                        return first[keyPath: keyPath] < second[keyPath: keyPath]
                    }
                case .desc:
                    if first[keyPath: keyPath] != second[keyPath: keyPath] {
                        return first[keyPath: keyPath] > second[keyPath: keyPath]
                    }
                }
            }
            return false // Default case (should not be reached)
        }
    }
}
