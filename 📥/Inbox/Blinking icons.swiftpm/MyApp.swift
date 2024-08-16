import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        
        WindowGroup {
            Card(emoji: "😯")
        }
    }
}

struct Card: View {
    @State var isEditing = false
    let emoji: String
    var body: some View {
        if isEditing {
            BlinkinCard(isEditing: $isEditing, emoji: emoji)
        } else {
            StaticCard(emoji: emoji)
                .onLongPressGesture { 
                    isEditing = true
                }
        }
    }
}

struct BlinkinCard: View {
    
    @State var isAnimating = false
    @Binding var isEditing: Bool
    let emoji: String
    
    var body: some View {
        StaticCard(emoji: emoji)
            .rotationEffect(Angle(degrees: isAnimating ? 6 : 0))
            .animation(animation, value: isAnimating)
            .onTapGesture { isEditing = false }
            .onAppear(perform: startAnimating)
    }
    
    var animation: Animation { 
        Animation.linear(duration: 0.1).repeatForever()
    }
    
    func startAnimating() { isAnimating = true }
}

extension View {
    func onTap(action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            self
        }
    }
}

struct StaticCard: View {
    
    let emoji: String
    
    var body: some View {
        Color(uiColor: .secondarySystemBackground)
            .frame(width: 80)
            .frame(height: 80)
            .cornerRadius(12)
            .overlay(Text(emoji))
    }
}
