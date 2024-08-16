//
//  ContentView.swift
//  CodableDatabase
//
//  Created by Cristian Felipe Patiño Rojas on 22/12/2023.
//
import Core
import SwiftUI

struct ContentView: View, Persistable {
    let id: UUID
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(id: UUID())
    }
}
