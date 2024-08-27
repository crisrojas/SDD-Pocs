//
//  _arrayidentifiable.swift
//  UIPlayground
//
//  Created by Cristian Felipe Patiño Rojas on 02/04/2024.
//

import Foundation

extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        get { first { $0.id == id } }
        set(newValue) {
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
}
