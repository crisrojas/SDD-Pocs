//
//  Subscript array como un diccionario.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//

import Foundation

import Foundation

extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element {
        get {
            self.first(where: { $0.id == id })!
        }
        
        set {
            print("new value: \(newValue)")
            self = self.filter { $0.id != id } + [newValue]
            print("self: \(self)")
        }
    }
}

//protocol Updatable {
//    associatedtype UpdateType
//    func update(_ update: UpdateType) -> Self
//}

struct CustomType {
    let id: String
    fileprivate(set) var someOptionalData: String?
}

protocol IdentifiableUpdatable: Identifiable, Updatable {}

extension CustomType: IdentifiableUpdatable {
    typealias UpdateType = Update
    enum Update {
        case someOptionalData(String?)
    }
    
    func update(_ update: Update) -> CustomType {
        var copy = self
        switch update {
        case .someOptionalData(let data): copy.someOptionalData = data
        }
        return copy
    }
}

extension Array where Element: Identifiable {
    mutating func update(_ element: Element) {
        self = self.filter { $0.id != element.id } + [element]
    }
}

extension Array where Element: IdentifiableUpdatable {
    mutating func update(_ element: Element, with update: Element.UpdateType) {
        self = self.filter { $0.id != element.id } + [element.update(update)]
    }
}

var array = Array(0...3).map { CustomType(id: $0.description, someOptionalData: nil) }

//print(array["0"])
////array["0"] = CustomType(id: "modified 0", someOptionalData: "not nil anymore")
////print(array["0"]) // Crashes because we're modifyng the id
//let firstItem = array["0"]
//array[firstItem.id] = firstItem.update(.someOptionalData("hello"))
//print(array["0"].someOptionalData!)
//
//array.update(firstItem, with: .someOptionalData("test"))
//print(array["0"].someOptionalData!)
//
