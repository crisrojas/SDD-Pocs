//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

struct MenuRow: View {
    let model: MenuItem
    var body: some View {
        HStack(spacing: .sizing(1.5)) {
            Image(systemName: model.icon)
                .scaleEffect(1.1)
                .foregroundColor(model.iconColor)
            
            Text(model.label)
            Spacer()
            Text("3").foregroundColor(.gray)
        }
        .contentShape(Rectangle())
        .font(.headline)
        .fontWeight(.black)
        .padding(.vertical, .sizing(3))
        .padding(.horizontal, .sizing(2))
        .cornerRadius(.sizing())
    }
}
