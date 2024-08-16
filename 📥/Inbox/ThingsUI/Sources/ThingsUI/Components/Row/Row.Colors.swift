//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 26/08/2023.
//

import SwiftUI

extension Row {
    /// Allows injecting custom dark and light scheme
    struct ColorHandler {
        private let dark : Row.Colors
        private let light: Row.Colors
        
        private let scheme: ColorScheme
        var colors: Row.Colors {
            switch scheme {
            case .dark: return dark
            default: return light
            }
        }
        init(scheme: ColorScheme, dark: Row.Colors, light: Row.Colors) {
            self.scheme = scheme
            self.dark = dark
            self.light = light
        }
        
        /// Init with default dark & light color palette
        init(scheme: ColorScheme) {
            self.scheme = scheme
            dark = Colors(scheme: .dark)
            light = Colors(scheme: .light)
        }
    }
    
    struct Colors {
        let icon: Color
        let iconSelected: Color
        let text: Color
        let textSelected: Color
        let textUnsetted: Color
        let textUnsettedSelected: Color
        let radioButton: Color
        let radioButtonSelected: Color
        let radioButtonDragging: Color
        let swipeLeading: Color
        let swipeTrailing: Color
        let swipeSelecting: Color
        let background: Color
        let backgroundSelected: Color
        let backgroundSwiping: Color
        let backgroundSelectedSwiping: Color
//        let backgroundBorder: Color // @todo
        
        var radioButtonColors: Row.RadioButton.Colors {
            .init(default: radioButton, selected: radioButtonSelected, dragging: radioButtonDragging)
        }
    }
}

// MARK: - Default colors
extension Row.Colors {
    init(scheme: ColorScheme) {
        if scheme == .light {
            icon = WindColor.zinc.c400
            iconSelected = WindColor.zinc.c400
            text = .black
            textSelected = .black
            textUnsetted = WindColor.zinc.c400
            textUnsettedSelected = WindColor.zinc.c400
            radioButton = WindColor.zinc.c400
            radioButtonSelected = .blue(._700)
            swipeLeading = .customYellow
            swipeTrailing = .blue(._500)
            swipeSelecting = .blue(._500)
            background = .white
            backgroundSwiping = .blue(._100)
            backgroundSelected = .blue(._200)
            backgroundSelectedSwiping = .blue(._100)
//            backgroundBorder = WindColor.zinc.c300
            radioButtonDragging = radioButton // @todo
        } else {
            let unselectedLabelColor = Color(r: 119, g: 144, b: 180)
            icon = WindColor.zinc.c500
            iconSelected = unselectedLabelColor
            text = .white
            textSelected = .white
            textUnsetted = Color(r: 113, g: 120, b: 130)
            textUnsettedSelected = unselectedLabelColor
            radioButton = WindColor.zinc.c500
            radioButtonSelected = Color(r: 99, g: 160, b: 247)
            swipeLeading = .customYellow
            swipeTrailing = .blue(._500)
            swipeSelecting = .blue(._500)
            background = .black
            backgroundSwiping = Color(r: 25, g: 33, b: 44)
            backgroundSelected = Color.darkBlue
            backgroundSelectedSwiping = Color.darkestBlue
//            backgroundBorder = .clear
            radioButtonDragging = Color.darkestBlue
        }
    }
}
