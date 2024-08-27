//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

struct QuickSearchField: View {
    
    var body: some View {
        Rectangle()
            .frame(height: .QuickSearch.barHeight)
            .cornerRadius(8)
            .foregroundColor(.systemGray5)
            .overlay(label)
    }
    
    var label: some View {
        HStack(spacing: .sizing(2.5)) {
            Image(systemName: "magnifyingglass")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 18)
               
            Text("Búsqueda rápida")
                .fontWeight(.bold)
                .font(.callout)
        }
        .foregroundColor(.systemGray)
    }
}
