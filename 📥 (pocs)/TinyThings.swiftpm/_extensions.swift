//
//  _extensions.swift
//  UIPlayground
//
//  Created by Cristian Felipe Patiño Rojas on 02/04/2024.
//

import SwiftUI


extension Bool {
    var isFalse: Bool { self == false }
}


extension [Todo] {
    func unchecked() -> Self {
        filter { $0.isChecked.isFalse }
    }
}

extension View {
    func maxWidth(_ value: CGFloat) -> some View {
        self.frame(maxWidth: value)
    }
    
    func side(_ value: CGFloat) -> some View {
        self.frame(width: value, height: value)
    }
    
    func top(_ value: CGFloat) -> some View {
        self.padding(.top, value)
    }
}


extension String: View {
    public var body: Text {
        Text(self)
    }
}
