//
//  File.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 09/05/2023.
//

import SwiftUI

typealias VoidFunc = () -> Void

extension View {
    func buttonify(action: @escaping VoidFunc) -> some View {
        Button(action:action, label: {self})
    }
    
    func navLinkify<D: View>(destination d: D) -> some View {
        NavigationLink(destination: d, label: {self})
    }
}
