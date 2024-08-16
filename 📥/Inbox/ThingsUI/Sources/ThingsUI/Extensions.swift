//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

extension CGFloat {
    static let base = 4.0
    static func sizing(_ factor: Double = 1) -> Self { factor * base}
}


extension CGFloat {
    enum QuickSearch {
        static let barHeight: CGFloat = .sizing(8)
    }
}

extension Color {
    static let systemGray = Color(uiColor: .systemGray)
    static let systemGray2 = Color(uiColor: .systemGray2)
    static let systemGray3 = Color(uiColor: .systemGray3)
    static let systemGray4 = Color(uiColor: .systemGray4)
    static let systemGray5 = Color(uiColor: .systemGray5)
    static let systemGray6 = Color(uiColor: .systemGray6)
    static let systemBackground = Color(uiColor: .systemBackground)
}

extension CGFloat {
    static var statusBarHeight: CGFloat? {
        guard
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let height = scene.statusBarManager?.statusBarFrame.height
        else {
            return nil
        }
        return height
    }
}
