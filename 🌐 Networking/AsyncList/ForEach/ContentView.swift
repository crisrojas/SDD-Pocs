//
//  ContentView.swift
//  ForEach
//
//  Created by Cristian Felipe Patiño Rojas on 12/03/2024.

import SwiftUI

struct ContentView: AsyncList {
    
    var url: String = "http://localhost:3000/users"
    
    func row(_ item: MJ) -> some View {
        (item.firstName << item.lastName)
            .navigateTo(ProductList(id: item.id.intValue))
            .disabled(item.type != "seller")
    }
}
