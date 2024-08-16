//
//  _ext.swift
//  ForEach
//
//  Created by Cristian Felipe Patiño Rojas on 01/04/2024.
//

import Foundation



extension View {
    func navigateTo<T: View>(_ view: T) -> NavigationLink<Self, T> {
        NavigationLink { view } label: { self }
    }
}

func << (lhs: String, rhs: String) -> String {
    lhs + " " + rhs
}


extension Array {
    func appending(_ element: Element) -> Self {
        var copy = self
        copy.append(element)
        return copy
    }
}

import SwiftUI

extension View {
    func insideNavigation() -> some View {
        NavigationView { self }
    }
}

