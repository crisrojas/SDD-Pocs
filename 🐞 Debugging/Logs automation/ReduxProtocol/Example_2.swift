//
//  ReduxBis.swift
//  ReduxProtocol
//
//  Created by Cristian Felipe Patiño Rojas on 21/12/2023.
//

import SwiftUI

struct SomeState: Equatable {
    var greeting = ""
}

protocol Logger {}
extension Logger {
    func log<T>(_ prev: T, _ new: T) {
        let children1 = Mirror(reflecting: prev).children
        let children2 = Mirror(reflecting: new).children
        
        for (prev, current) in zip(children1, children2) {
            if "\(prev.value)" != "\(current.value)" {
                print("\(prev.label ?? "") <- \(current.value)")
            }
        }
    }
}

struct Example_2: View, Logger {
    
    @State var store = SomeState() {
        willSet { log(store, newValue) }
    }
    
    static var title = "Example_2"
    
    var body: some View {
        VStack {
            Text(store.greeting)
            Button("Update state", action: action)
        }
    }
    
    func action() {
        store.greeting = "hello world"
    }
}
