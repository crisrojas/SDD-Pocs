//
//  ContentView.swift
//  ReduxProtocol
//
//  Created by Cristian Felipe Patiño Rojas on 19/12/2023.
//

import SwiftUI

struct Mind {
    var name = ""
}

extension State {
    @_disfavoredOverload
    init(_ initialValue: Value) {
        self = .init(initialValue: initialValue)
    }
    
    
    init(_ initialValue: () -> Value) {
        self = .init(initialValue: initialValue())
    }
}


struct Example_1: ReduxView {
    var store = State(Mind.init)
    static var title = "Example_1"
    var body: some View {
        VStack {
            Text(store.wrappedValue.name)
            
            Button("Change") {
                effect(action.map { $0.name = "hello" })
            }
        }
    }
}
