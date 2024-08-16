//
//  Profile.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 12/04/2024.
//

import SwiftUI

struct Profile: View {
    
    @AppStorage("username") var username: String = ""
    @AppStorage("colorScheme") var preferredScheme: ColorScheme?
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.theme) var theme
    
    var body: some View {
        List {
            Section("User name") {
                // @todo: username change doesn't updates
                // immediately on home screen...
                // logs:
                // === AttributeGraph: cycle detected through attribute XXXXX ===
                TextField("Username", text: $username)
            }
            Section("Appearance") {
                systemRow
                row(scheme: .light)
                row(scheme: .dark)
            }
        }
    }
    
    var systemRow: some View {
        HStack(spacing: .s4) {
            systemRectangle
            
            "Automatic".body.fontWeight(.bold).foregroundColor(theme.textPrimary)
            
            Spacer()
            
            if preferredScheme == nil {
                checkmark
            }
        }
        .onTap { preferredScheme = nil }
    }
    
    var systemRectangle: some View {
        ZStack{
            schemeIcon(scheme: .light)
            schemeIcon(scheme: .dark)
                .clipShape(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: .s7))
                        path.addLine(to: CGPoint(x: .s7, y: 0))
                        path.addLine(to: CGPoint(x: .s7, y: .s7))
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
            .size(.s7)
            .foregroundColor(scheme == .dark ? .black : .white)
            .cornerRadius(.s1)
            .overlay("A".font(.title2).foregroundColor(scheme == .dark ? .white : .black))
            .background(
                Rectangle()
                    .foregroundColor(scheme == .dark ? .stone900 : .stone400)
                    .cornerRadius(.s1h)
                    .size(.s8)
            )
    }

    func row(scheme: ColorScheme) -> some View {
        HStack(spacing: .s4) {
           schemeIcon(scheme: scheme)
            (scheme == .dark ? "Dark" : "Light").body.fontWeight(.bold).foregroundColor(theme.textPrimary)
            Spacer()
            if preferredScheme == scheme {
                checkmark
            }
        }
        .onTap { preferredScheme = scheme }
    }
    
    var checkmark: some View {
        Image(systemName: "checkmark")
            .foregroundColor(.blue500)
            .modify {
                if #available(iOS 16.0, *) {
                    $0.fontWeight(.bold)
                }
            }
    }
}
