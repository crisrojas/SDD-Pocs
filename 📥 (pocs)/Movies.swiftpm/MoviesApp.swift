import SwiftUI

enum Globals {
    static let tabState = TabState()
}

struct VideoURL {
    var prevState: (String, URL)?
    var currentState: (String, URL)?
    
    var id: String? {
        if let prevState {
            return prevState.0
        }
        
        return currentState?.0
    }
    
    var url: URL? {
        if let prevState {
            return prevState.1
        }
        return currentState?.1
    }
}

final class TabState: ObservableObject {
    @Published var videoURL: URL?
    @Published var selectedTab = Tab.home
}

@main
struct MoviesApp: App {
    var body: some Scene {
        WindowGroup {
            Schemer {
                Tabbar()
                    .onAppear(perform: hideBackButtonLabel)
                    .onAppear(perform: hideTabbar)
                    .onAppear(perform: configureCachePolicy)
            }
        }
    }
}

fileprivate func configureCachePolicy() {
    let cache = URLCache.shared
    let cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad
    let config = URLSession.shared.configuration
    config.urlCache = cache
    config.requestCachePolicy = cachePolicy
}

fileprivate func hideBackButtonLabel() {
    let backButton = UIBarButtonItem.appearance(whenContainedInInstancesOf: [UINavigationBar.self])
    backButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .normal)
    backButton.setTitleTextAttributes([.foregroundColor: UIColor.clear], for: .highlighted)
}

fileprivate func hideTabbar() {
   UITabBar.appearance().isHidden = true
}
