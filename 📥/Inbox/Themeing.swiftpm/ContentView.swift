//
//  Profile.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 12/04/2024.
//

import SwiftUI

struct Profile: View {
    @AppStorage("colorScheme") var preferredScheme: ColorScheme?
    @Environment(\.colorScheme) var colorScheme
  
    @Environment(\.theme) var theme
    var body: some View {
        List {
            Rectangle()
                .frame(width: 48)
                .frame(height: 48)
                .foregroundColor(theme.accentColor)
            
            Section("Appearance") {
                systemRow
                row(scheme: .light)
                row(scheme: .dark)
            }
        }
    }
    
    var systemRow: some View {
        HStack(spacing: 16) {
            systemRectangle
            Text("Automatic").fontWeight(.bold)
            Spacer()
            if preferredScheme == nil {
                checkmark
            }
        }
        .onTapGesture {
           preferredScheme = nil
        }
    }
    
    var systemRectangle: some View {
        ZStack{
            schemeIcon(scheme: .light)
            schemeIcon(scheme: .dark)
                .clipShape(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 28))
                        path.addLine(to: CGPoint(x: 28, y: 0))
                        path.addLine(to: CGPoint(x: 28, y: 28))
                        path.closeSubpath()
                    }
                )
        }
    }
    
    var superior: some View {
        Rectangle()
            .frame(width: 200, height: 200)
            .foregroundColor(.blue)
            .clipShape(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 200))
                    path.addLine(to: CGPoint(x: 200, y: 0))
                    path.addLine(to: CGPoint(x: 0, y: 0))
                    path.closeSubpath()
                }
            )

    }
    
    var inferior: some View {
        Rectangle()
            .frame(width: 200, height: 200)
            .foregroundColor(.blue)
            .clipShape(
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 200))
                    path.addLine(to: CGPoint(x: 200, y: 0))
                    path.addLine(to: CGPoint(x: 200, y: 200))
                    path.closeSubpath()
                }
            )
    }
    
    func schemeIcon(scheme: ColorScheme) -> some View {
        Rectangle()
            .frame(width: 28.0)
            .frame(height: 28.0)
            .foregroundColor(scheme == .dark ? .black : .white)
            .cornerRadius(4)
            .overlay(Text("A").font(.title2).foregroundColor(scheme == .dark ? .white : .black))
            .background(
                Rectangle()
                    .cornerRadius(6)
                    .frame(width: 28)
                    .frame(height: 28)
            )
    }

    func row(scheme: ColorScheme) -> some View {
        HStack(spacing: 16) {
           schemeIcon(scheme: scheme)
            Text(scheme == .dark ? "Dark" : "Light").fontWeight(.bold)
            Spacer()
            if preferredScheme == scheme {
                checkmark
            }
        }
        .onTapGesture {
            preferredScheme = scheme
        }

    }
    
    var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.blue)
    }
}
