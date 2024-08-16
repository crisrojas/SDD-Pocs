import Inject
import LocalPackage
import SwiftUI

struct HomeView: View {
    @ObservedObject private var iO = Inject.observer
    @State var selection: Int = 0
    var body: some View {
        TabView(selection: $selection) {
            ContentView()
                .tabItem { Text("teiddfdd") }
                .tag(1)
            
            MyCustomView()
            .tabItem { Text("tejjst") }
            .tag(2)
        }
        .environmentObject(AppViewModel())
        .enableInjection()
    }
}

struct MyCustomView: View {
    var body: some View {
        VStack {
            Text("hello world")
            Text("new view")
        }
        .background(
            Color.gray
        )
            
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
