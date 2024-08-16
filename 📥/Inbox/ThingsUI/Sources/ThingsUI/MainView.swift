//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

public struct MainView: View {
    public init() {}
    public var body: some View {
        NavigationView {
            ListView(model: ListView_Previews.model)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(projects: [])
    }
}
