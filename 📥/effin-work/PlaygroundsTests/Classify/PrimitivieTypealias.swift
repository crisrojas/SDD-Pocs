//
//  PrimitivieTypealias.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 22/11/23.
//

import SwiftUI

fileprivate typealias IntVoid    = (Int   ) -> Void
fileprivate typealias StringVoid = (String) -> Void
fileprivate typealias DoubleVoid = (Double) -> Void
fileprivate typealias BoolVoid   = (Bool  ) -> Void
fileprivate typealias Voided<T> = (T) -> Void

fileprivate struct AddCounter: View {
    @State var value: Int? = 0
    var create: IntVoid?
    var body: some View {
        VStack {
            IntTextField("Counter", value: $value)
            Button("Create counter") {
                guard let value else { return }
                create?(value)
            }
        }
    }
}

/// Move to its own playground.
fileprivate struct IntTextField: View {
    @Binding var value: Int?
    var placeholder: String = ""
    
    init(_ placeholder: String, value: Binding<Int?>) {
        self.placeholder = placeholder
        self._value = value
    }
    
    var body: some View {
        TextField(placeholder, text: $value.asString())
    }
}

extension Binding<Int?> {
   func asString() -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue?.description ?? "" },
            set: { self.wrappedValue = Int($0)          }
        )
    }
}

extension Binding<Double?> {
    func asString() -> Binding<String> {
         Binding<String>(
             get: { self.wrappedValue?.description ?? "" },
             set: { self.wrappedValue = Double($0)          }
         )
     }
}
