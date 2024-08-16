//
//  Shorter Singletons with Enums.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 22/11/23.
//

import Foundation

fileprivate final class SingletonClass {
    static let shared = SingletonClass()
    private init() {}
    func greet() {print("Greetings")}
}

func using_singleton_class_is_verbose() {
    /// Do someting:
    SingletonClass.shared.greet()
}

fileprivate enum SingletonEnum {
    static func greet() {print("Greetings")}
}

/// Using empty enum with static methods is similar to using singletons
/// But usage is less verbose:
func using_enum_is_less_verbose() {
    
    SingletonEnum.greet()
    // vs
    SingletonClass.shared.greet()
}

/// What about dependencies ?
/// You could always provide it via protocol extension.
/// You can make the protocol fileprivate and delcare it at the same place than your enum
/// That way, you ensure that is really the only instance you can have on the app
fileprivate protocol SingletonProtocol {
    static var someDependency: String {get}
}

extension SingletonProtocol {
    
    /// Downside: dependencies would be public
    static var someDependency: String {"hello"}
    static func doSomething() { print(Self.someDependency) }
}

extension SingletonEnum: SingletonProtocol {}

func using_enum_that_conforms_to_fileprivate_protocol() {
    SingletonEnum.doSomething()
}
