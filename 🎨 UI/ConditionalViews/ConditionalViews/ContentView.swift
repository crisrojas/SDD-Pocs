//
//  ContentView.swift
//  ConditionalViews
//
//  Created by Cristian Felipe Patiño Rojas on 04/08/2024.
//

import SwiftUI

struct ContentView: View {
    @State var optionalValue: String?
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            OptionalText(optionalValue)
            Button("Toggle value") {
               optionalValue = nextValue()
            }
        }
        .padding()
        .animation(.linear(duration: 0.2), value: optionalValue)
    }
    
    func nextValue() -> String? {
        optionalValue == nil
        ? "Hello world!"
        : nil
    }
}

struct OptionalText: View {
    let value: String?
    init(_ value: String?) {
        self.value = value
    }
    
    var body: some View {
        if let value {
            SwiftUI.Text(value)
        }
    }
}



#Preview {
    ContentView()
}
