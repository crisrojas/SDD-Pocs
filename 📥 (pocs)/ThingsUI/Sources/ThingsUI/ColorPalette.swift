//
//  ColorPalette.swift
//  ThingsKit
//
//  Created by Cristian Felipe Patiño Rojas on 26/08/2023.
//

import SwiftUI

struct ColorPalette: View {
    let model: [Color] = [.darkBlue, .darkestBlue, .customBlue, .lightBlue, .customYellow]
    
    var body: some View {
        List(model, id: \.self) { color in
            Rectangle().foregroundColor(color).frame(width: 40, height: 40)
        }
    }
}

struct ColorPalette_Previews: PreviewProvider {
    static var previews: some View {
        ColorPalette()
    }
}
