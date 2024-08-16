//
//  Redux in SwiftUI.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 22/11/23.
//

import Foundation
import SwiftUI

/// What you usually need
///
/// What SwiftUI gives you

struct Counter: Identifiable { let id: UUID ; let value: Int }
fileprivate struct AppState {
    var counters = [Counter]()
}

extension AppState {
    enum Update {
        case create(Counter)
    }
}

fileprivate final class Store: ObservableObject {
    @Published var state = AppState()
    
    func dispatch(_ update: AppState.Update) {
        // Perform some actions to update the store
        // Update encodes the changes a state can follow
    }
}

fileprivate struct CounterList: View {
    @EnvironmentObject var store: Store
    var body: some View {
        List(store.state.counters) { item in
            Text(item.value.asString)
        }
    }
    
    var body_2: some View {
        List(store.state.counters) { item in
            Text(item.value.asString)
        }
        .task {
            // Fetch data ?
        }
        .toolbar {
            NavigationLink {
                AddCounter()
            } label: {
                Text("+")
            }

        }
    }
}

fileprivate typealias IntVoid = (Int) -> Void

fileprivate struct AddCounter: View {
    @State var value: Int? = 0
    var create: IntVoid?
    var body: some View {
        IntTextField("Counter", value: $value)
    }
}

fileprivate struct IntTextField: View, Copiable {
    @Binding var value: Int?
    var placeholder: String = ""
    
    init(_ placeholder: String, value: Binding<Int?>) {
        self.placeholder = placeholder
        self._value = value
    }
    
    var binding: Binding<String> {
        Binding(
            get: { value?.description ?? "" },
            set: { value = Int($0)          }
        )
    }
    
    var body: some View {
        TextField(placeholder, text: binding)
    }
}
