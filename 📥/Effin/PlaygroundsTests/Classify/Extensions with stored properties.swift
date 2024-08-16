////
////  Extensions with stored properties.swift
////  PlaygroundsTests
////
////  Created by Cristian Felipe Patiño Rojas on 06/12/2023.
////
//
//import Foundation
//
//final class MyClass {
//    
//}
//
//extension MyClass {
//    
//    /// ❌ Extensions must not contain stored properties
//    // var myVar = ""
//}
//
//
//extension MyClass {
//
//    /// ❌ Cannot assign to property: 'myVar' is a get-only property
//    // var myVar: String { "hello" }
//    // func changeMyVar() {
//    //     myVar = "hello world"
//    // }
//}
//
//
//final class ValueWrapper<T> {
//    var value: T
//    
//    private init(_ value: T) {
//        self.value = value
//    }
//    
//    static func store(_ v: T) -> Self {
//        .init(v)
//    }
//}
//
//extension MyClass {
//    fileprivate var myVarStore: ValueWrapper<String> { .store("hello") }
//    var myVar: String {
//        get { myVarStore.value }
//        set { myVarStore.value = newValue }
//    }
//}
//
///// Works for protocols
//final class Store {
//    var data = [String]() { didSet {persist()}}
//    func persist() {}
//}
//
//
//protocol Persistable: Codable {
//    func create(_ item: Self)
//    func read  (            ) -> [Self]
//    func read  (_ item: UUID) -> Self?
//    func update(_ item: Self)
//    func delete(_ item: UUID)
//}
//
//final class AppStore {
//    var persistables: [String: [any Persistable]] = [:] {
//        didSet {persist()}
//    }
//    
//    init(persistables: [(any Persistable).Type]) {
//        persistables.map { persistable in
//            
//        }
//    }
//    
//    func create(_ item: some Persistable) {
//        let key = String(describing: type(of: item))
//    }
//    func read() -> [any Persistable] {[]}
//    func update(_ item: any Persistable) {}
//    func delete(id: UUID) {}
//    
//    func persist() {}
//}
//
//
//fileprivate struct ToDo: Persistable {
//    func create(_ item: ToDo) {
//        
//    }
//    
//    func read() -> [ToDo] {
//        []
//    }
//    
//    func read(_ item: UUID) -> ToDo? {
//        nil
//    }
//    
//    func update(_ item: ToDo) {
//        
//    }
//    
//    func delete(_ item: UUID) {
//        
//    }
//}
//
//let persistable: (some Persistable).Type = ToDo.self
//
////let appStore = AppStore(persistables: [ToDo.self])
