//
//  Tabbar.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 12/04/2024.
//

import SwiftUI
import SafariServices

enum Tab: String, View, CaseIterable {
    case home
    case favorites
    case button
    case stars
    case profile
    
    var systemName: String {
        switch self {
        case .home     : return "house"
        case .favorites: return "heart"
        case .button   : return "popcorn"
        case .stars    : return "star"
        case .profile  : return "person"
        }
    }
    
    @ViewBuilder
    var screen: some View {
        switch self {
        case .home     : Home()
        case .button   : Genres()
        case .stars    : Ratings()
        case .profile  : Profile()
        case .favorites: Favorites()
        }
    }
    
    var body: some View {
        screen
            .navigationify()
            .tabItem {
                Label(rawValue, systemImage: systemName)
            }
            .tag(self)
    }
}

struct Tabbar: View {
    
    @StateObject var states = Globals.tabState
    @Environment(\.theme) var theme
    
    var body: some View {
        VStack {
            tabs
            customTabbar
        }
        .accentColor(theme.accent)
        .edgesIgnoringSafeArea(.bottom)
    }
    
    var tabs: some View {
        TabView(selection: $states.selectedTab) {
            ForEach(Tab.allCases, id: \.self) { $0 }
        }
    }

    var customTabbar: some View {
        VStack {
            HStack {
                ForEach(Tab.allCases, id: \.self) { tab in
                    if tab != .button {
                        defaultItem(tab)
                    } else {
                        CentralButton(videoURL: states.videoURL)
                        .onTap {
                            if let videoURL = states.videoURL {
                                presentVideo(url: videoURL)
                            } else {
                                states.selectedTab = tab
                            }
                        }
                        .buttonStyle(ScaleStyle(duration: 0.1))
                    }
                }
            }
            .height(.s14)
           
            Rectangle()
                .height(.safeAreaInset(.bottom))
                .foregroundColor(theme.tabbarBg)
        }
        .background(theme.tabbarBg)
    }
    
    func defaultItem(_ tab: Tab) -> some View {
        Item(name: tab.rawValue, systemImage: tab.systemName)
            .opacity(states.selectedTab == tab ? 1 : 0.3)
            .foregroundColor(theme.textPrimary)
            .height(.s14)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .onTap { states.selectedTab = tab }
//            .buttonStyle(ScaleStyle(duration: 0.05))
    }
    
    func presentVideo(url: URL) {
        
        let safariViewController = SFSafariViewController(url: url)
        UIApplication.shared.windows.first?.rootViewController?.present(safariViewController, animated: true, completion: nil)
    }
}

extension Tabbar {
    struct CentralButton: View {
        @StateObject var tabState = Globals.tabState
        @Environment(\.theme) var theme: Theme
        let videoURL: URL?
        
        var symbolName: String {
            videoURL == nil ? "popcorn" : "play.circle"
        }
        
        var defaultColor: Color {
            tabState.selectedTab == .button ? theme.circleButtonSecondary : theme.circleButtonDefault
        }
        
        var color: Color {
            videoURL == nil ? defaultColor : theme.circleButtonSecondary
        }
        
        var body: some View {
            Circle()
                .size(.s16)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.5), radius: 10)
                .overlay(symbol)
                .background(
                    Circle()
                        .foregroundColor(theme.tabbarBg)
                        .size(.s20)
                )
                .offset(y: -.s3h)
                .animation(.linear, value: videoURL == nil)
        }
        
        var symbol: some View {
            Image(systemName: symbolName)
                .modify {
                    if #available(iOS 16.0, *) {
                        $0.fontWeight(.bold)
                    }
                }
                .foregroundColor(.white)
                .scaleEffect(1.3)
        }
    }
}

extension Tabbar {
    struct Item: View {
        let name: String
        let systemImage: String
        
        var body: some View {
            VStack {
                Image(systemName: systemImage)
                    .scaleEffect(1.3)
            }
            .accessibilityLabel(name)
        }
    }
}
