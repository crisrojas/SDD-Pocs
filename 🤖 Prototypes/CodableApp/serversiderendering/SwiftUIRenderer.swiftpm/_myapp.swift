import SwiftUI

enum Api {
    static let baseURL = "http://127.0.0.1:8000"
    static func path(_ string: String) -> String {
        baseURL + "/" + string + ".json"
    }
}

extension Application: View {
    var body: some View {main.body.body()}
    
    var main: ComponentOwner {
        TabView {
            screen1.tabItem(DSL.Label(title: "item 1", systemImage: "plus"))
            screen2.tabItem(DSL.Label(title: "item 2", systemImage: "plus"))
        }
    }
    
    var screen1: ComponentOwner {
        NavigationView {
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Link(url: Api.path("view"), label: Text("hello"))
                    Spacer()
                }
               
                Spacer()
            }
            .background(Color.blue100)
        }
    }
    
    var screen2: ComponentOwner {
        Text("hello world")
    }
}


@main
struct MyAppBis: App {
    
    let app = Application()
                                  
    var body: some Scene {
        WindowGroup {
            app.onAppear { print(app.screen1.body.prettyPrinted())}
        }
    }
}

