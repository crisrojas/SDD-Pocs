//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

struct MenuItemStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        
        let bg = configuration.isPressed
        ? Color.systemGray6
        : Color.systemBackground
        
        return configuration.label
            .background(bg.cornerRadius(.sizing()))
            .animation(.linear(duration: 0.01), value: configuration.isPressed)
    }
}
