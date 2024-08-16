//
//  Usage with environment object.swift
//  ReduxProtocol
//
//  Created by Cristian Felipe Patiño Rojas on 21/12/2023.
//

import SwiftUI

class GlobalState: ObservableObject, Redux {
   
    @Published var store = Mind()
    
    var binding: Binding<Mind> {
        Binding<Mind>(
            get: { self.store },
            set: { self.store = $0 }
        )
    }
}


struct Example_3: View {
    @StateObject var state = GlobalState()
    static var title = "Example_3"
    var body: some View {
        VStack {
            Text(state.store.name)
            Button("Change store") {
                state.effect({$0.name = "hello world"})
            }
        }
    }
}
