//
//  Reactivity.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 19/11/23.
//
fileprivate final class UILabel  {var text  = ""}
fileprivate final class UIButton {var title = ""}

fileprivate struct Rx<T> {
    var call: ((T) -> ())?
    var value: T { didSet {call?(value)} }
    init(_ v: T) {self.value = v}
}

extension Rx where T == String {
    mutating func bind(_ view: UILabel) {
        call = { view.text = $0 }
    }
    
    mutating func bind(_ view: UIButton) {
        call = { view.title = $0 }
    }
}

//infix operator ~<: AdditionPrecedence
//func ~<<U>(_ lhs: inout Rx<U>, _ rhs: (keyPath: WritableKeyPath<U, U>, value: U)) {
//    lhs.value[keyPath: rhs.keyPath] = rhs.value
//}


infix operator ~<: AdditionPrecedence
fileprivate func ~<<U, Value>
(_ lhs: inout Rx<Value>,
 _ rhs: (
    ReferenceWritableKeyPath<U, Value>,
    on: U
 )
) {
    lhs.call = { value in
        rhs.1[keyPath: rhs.0] = value
    }
}

infix operator ~=
fileprivate func ~=<U>(_ lhs: inout Rx<U>, _ value: U) {
    lhs.value = value
}

final class CustomView: KeyPathMutable {
    var label = "uilabel"
}

fileprivate final class Rx_Test_ViewController {
    
    lazy var label = UILabel()
    lazy var view = CustomView()
    
    fileprivate var name = Rx("hello")
    
    func viewDidLoad() {
        name ~< (\.text, on: label)
        name.bind(label)
    }
}
