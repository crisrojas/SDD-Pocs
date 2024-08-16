import SwiftUI

struct ContentView: View {
    @State private var count = 0
    var body: some View {
        VStack(spacing: 14) {
            Text(count.description)
                .font(.largeTitle)
            HStack(spacing: 0) {
                Button {} label: { 
                    Rectangle()
                        .foregroundColor(Color(uiColor: .systemGray4))
                        .frame(width: 42)
                        .frame(height: 30)
                        .overlay(Image(systemName: "minus"))
                        .cornerRadius(7)
                }
                    .buttonStyle(PerformWhilePressButtonStyle(action: decrease))
                
                Rectangle()
                    .frame(width: 1)
                    .frame(height: 18)
                    .foregroundColor(Color(uiColor: .systemGray2))
                
                Button {} label: { 
                    Rectangle()
                        .foregroundColor(Color(uiColor: .systemGray4))
                        .frame(width: 42)
                        .frame(height: 30)
                        .overlay(Image(systemName: "plus"))
                        .cornerRadius(7)
                }
                .buttonStyle(PerformWhilePressButtonStyle(action: increase))
            }
            .background(Color(uiColor: .systemGray4).cornerRadius(7))
        }
    }
    
    func increase() { count += 1 }
    func decrease() { count -= 1 }
}


struct PerformWhilePressButtonStyle: ButtonStyle {
    @StateObject private var listener = PressListener()
    let action: () -> Void
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.5 : 1)
            .onChange(of: configuration.isPressed) { newValue in
                if newValue {
                    listener.startTimer(performing: action)
                } else {
                    listener.stopTimer()
                }
            }
    }
    
    private final class PressListener: ObservableObject {
        
        private var timer: Timer?
        
        func startTimer(performing action: @escaping () -> Void) {
            timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in 
                action()
            }
        }
        
        func stopTimer() {
            timer?.invalidate()
            timer = nil
        }
    }
}
