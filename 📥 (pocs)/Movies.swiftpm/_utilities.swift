//
//  _utilities.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import Foundation

protocol Initiable {init()}
extension Initiable {
    init(transform: (inout Self) -> Void) {
        var copy = Self.init()
        transform(&copy)
        self = copy
    }
}

import SwiftUI
protocol Component: SwiftUI.View, Initiable {}
protocol TapInjectable {
    var _onTap: () -> Void {get set}
}

extension TapInjectable {
    func onTap(cls: @escaping () -> Void) -> Self {
        var copy = self
        copy._onTap = cls
        return copy
    }
}

func youtubeURL(key: String) -> URL? {
    URL(string: "https://youtube.com/watch?v=\(key)")
}

infix operator *: AdditionPrecedence
func * <T>(lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}


protocol FeedbackGenerator { }
extension FeedbackGenerator {
    var soft   : UIImpactFeedbackGenerator {UIImpactFeedbackGenerator(style: .soft)}
    var light  : UIImpactFeedbackGenerator {UIImpactFeedbackGenerator(style: .light)}
    var heavy  : UIImpactFeedbackGenerator {UIImpactFeedbackGenerator(style: .heavy)}
    var medium : UIImpactFeedbackGenerator {UIImpactFeedbackGenerator(style: .medium)}
    var rigid  : UIImpactFeedbackGenerator {UIImpactFeedbackGenerator(style: .rigid)}
    
    func generateFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .soft  : soft.impactOccurred()
        case .light : light.impactOccurred()
        case .heavy : heavy.impactOccurred()
        case .medium: medium.impactOccurred()
        case .rigid : rigid.impactOccurred()
        @unknown default: medium.impactOccurred()
        }
    }
}
