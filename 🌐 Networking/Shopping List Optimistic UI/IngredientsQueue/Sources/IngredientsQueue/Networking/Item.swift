//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 15/08/2024.
//

import Foundation

struct Item: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    var isChecked: Bool
}
