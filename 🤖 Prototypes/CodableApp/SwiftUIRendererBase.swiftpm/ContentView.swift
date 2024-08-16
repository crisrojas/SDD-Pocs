import SwiftUI

struct ContentView: View {
    var body: some View {
        Models.VStack.ComponentView(
        
            Models.VStack {
                Models.Text("hello world")
            }
        )
        
    }
}
