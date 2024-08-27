import SwiftUI

import SwiftUI
import Combine

@propertyWrapper
struct State<T: Equatable>: DynamicProperty {
    @StateObject private var storage: Storage<T>
    
    var wrappedValue: T {
        get { storage.value }
        nonmutating set { storage.value = newValue }
    }
    
    var projectedValue: Binding<T> {
        Binding(
            get: { storage.value },
            set: { storage.value = $0 }
        )
    }
    
    init(wrappedValue: T) {
        _storage = StateObject(wrappedValue: Storage(value: wrappedValue))
    }
    
    private class Storage<A: Equatable>: ObservableObject {
        @Published var value: A {
            didSet {
                if oldValue != value {
                    print("\(oldValue) -> \(value)")
                }
            }
        }
        
        init(value: A) {
            self.value = value
        }
    }
}

struct ContentView: View {
    @State var myVar = ""
    
    var body: some View {
        VStack {
            Text(myVar)
            TextField("Enter text", text: $myVar)
        }
    }
}
