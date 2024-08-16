//
//  Wrapper.swift
//  Networking
//
//  Created by Cristian Felipe Patiño Rojas on 01/12/2023.
//

import Foundation

public struct Wrapper<T:Codable>: Codable {
    public let data: T
    
    public init(data: T) {
        self.data = data
    }
}
