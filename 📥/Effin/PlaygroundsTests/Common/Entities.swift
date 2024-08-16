//
//  Common entities.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 21/11/23.
//

import Foundation

struct User: Mappable, Identifiable, Codable {
    let id: UUID
    var firstName: String
    var lastName: String
    
    init(id: UUID = UUID(), firstName: String, lastName: String) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
    }
}
