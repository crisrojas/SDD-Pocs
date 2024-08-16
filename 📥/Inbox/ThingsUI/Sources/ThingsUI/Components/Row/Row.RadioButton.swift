//
//  Row.RadioButton.swift
//  ThingsKit
//
//  Created by Cristian Felipe Patiño Rojas on 26/08/2023.
//

import SwiftUI

extension Row {
    struct RadioButton: View {
        let isDragging: Bool
        let isSelected: Bool
        let colors: Colors
        enum Constants {
            static let size = 25.0
            static let filledSize = 16.0
        }
        
        var body: some View {
            Image(systemName: "circle")
            
                .resizable()
                .fontWeight(.light)
                .frame(width: Constants.size,
                       height: Constants.size)
                .overlay(filledCircle)
                .foregroundColor(
                    isDragging
                    ? isSelected ? colors.selected : colors.dragging
                    : isSelected ? colors.selected : colors.default
                )
                .scaleEffect(isDragging ? 1.25 : 1)
                .animation(.linear(duration: 0.1), value: isDragging)
        }
        
        var filledCircle: some View {
            Image(systemName: "circle.fill")
                .resizable()
                .frame(width: Constants.filledSize, height: Constants.filledSize)
                .scaleEffect(isSelected ? 1 : 0.5)
                .foregroundColor(colors.selected)
            // prevents "ignoring singular matrix" log noise
                .opacity(isSelected ? 1 : 0)
        }
    
    }
}

extension Row.RadioButton {
    struct Colors {
        let `default`: Color
        let selected: Color
        let dragging: Color
    }
}


struct Row_SelectionCircle_Previews: PreviewProvider {
    static var previews: some View {
        Row.RadioButton(
            isDragging: false,
            isSelected: false,
            colors: Row.Colors(scheme: .light).radioButtonColors
        )
        .previewLayout(.sizeThatFits)
    }
}
