//
//  _entities.swift
//  UIPlayground
//
//  Created by Cristian Felipe Patiño Rojas on 02/04/2024.
//

import Foundation

struct Todo: Entity {
    let id = UUID()
    var description: String
    var isChecked = false
    
    init(_ description: String) {
        self.description = description
    }
}

