//
//  Colors.swift
//  ThingsKit
//
//  Created by Cristian Felipe Patiño Rojas on 26/08/2023.
//

import SwiftUI

extension Color {
    static let isDarkMode = UIViewController().isDarkMode
    static var defaultTextColor: Color {
        Color.isDarkMode ? .white : .black
    }
    static let darkestBlue = Color(red: 32/255, green: 57/255, blue: 107/255)
    static let darkBlue = Color(red: 32/255, green: 64/255, blue: 115/255)
    static let customBlue = Color(red: 103/255, green: 172/255, blue: 255/255)
    static let lightBlue = Color(red: 162/255, green: 189/255, blue: 225/255)
    static let customYellow = Color(red: 255/255, green: 212/255, blue: 0/255)
    
    static func blue(_ shade: ColorShade) -> Color {
        switch shade {
        case ._100: return Color(r: 225, g: 234, b: 245)
        case ._200: return Color(r: 213, g: 228, b: 252)
        case ._500: return Color(r:  96, g: 149, b: 241)
        case ._700: return Color(r:  79, g: 123, b: 198)
        default: fatalError("Not implemented yet")
        }
    }
}

extension Color {
    init(r: Int, g: Int, b: Int) {
        precondition(r <= 255 && g <= 255 && b <= 255)
        let red   = Double(r) / 255
        let green = Double(g) / 255
        let blue  = Double(b) / 255
        self = Color(red: red, green: green, blue: blue)
    }
}

enum RGB {
    
}
enum ColorShade {
    case _100
    case _200
    case _300
    case _400
    case _500
    case _600
    case _700
    case _800
    case _900
}

extension UIViewController {
    var isDarkMode: Bool {
        if #available(iOS 13.0, *) {
            return self.traitCollection.userInterfaceStyle == .dark
        }
        else {
            return false
        }
    }
}
