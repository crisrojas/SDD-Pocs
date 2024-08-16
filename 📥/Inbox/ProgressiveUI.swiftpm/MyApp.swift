import SwiftUI

struct Component {
    @AppStorage("Component.count") var count = 0
    var body: some View {
        Text("hello world")
    }
    // has usado este componente 10 veces
    // consideramos que ya has aprendio a usarlo
    // deseas ocultarlo ?
}

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
