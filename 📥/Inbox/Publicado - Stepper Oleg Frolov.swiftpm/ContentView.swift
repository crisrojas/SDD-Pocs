import SwiftUI


import Combine

/// Tried to implement one of the Oleg Frolov takes on steppers:
/// https://dribbble.com/shots/5614928-Stepper-XVII

struct StepperView: View {
    
    @StateObject private var manager = Manager()
    @GestureState private var isDragging = false
    @State private var offset = CGFloat.zero
    let color: Color
    
    private let size = 64.0
    
    init(color c: Color = .accentColor) {color = c}
    func tintColor(_ color: Color) -> Self {.init(color: color) } 
    
    @State private var stepperCount = 0
    var body: some View {
        main
    }
    
    var main: some View {
        VStack {
            chevron(up: true)
            Rectangle()
                .foregroundColor(manager.count > 0 ? color : .gray)
                .brightness(isDragging ? 0.1 : 0)
                .frame(width: size)
                .frame(height: size)
                .cornerRadius(20)
                .overlay(label)
                .clipped(antialiased: true)
                .shadow(color: (manager.count > 0 ? color : .gray).opacity(0.10), radius: 4, x: 0, y: 16)
                .scaleEffect(isDragging ? 0.90 : 1)
                .animation(.interpolatingSpring(stiffness: 300, damping: 10), value: isDragging)    
                .offset(y: offset)
                .gesture(dragGesture)
                .zIndex(2)
                .padding(.vertical, 18)
            
            chevron(up: false)
        }
        .onChange(of: isDragging) {if !$0 { manager.stop() ; print("should stop") }}
        .onChange(of: offset) { newValue in 
            if offset ==  40 && !hasStarted { hasStarted = true ; manager.start(adding:  true) }
            if offset == -40 && !hasStarted { hasStarted = true ; manager.start(adding: false) }
        }
    }
    
    @State private var hasStarted = false
    func chevron(up: Bool) -> some View {
        let action = up ? {manager.substract()} : {manager.add()}
        let disabled = manager.count == 0
        return Button(action: action, label: {
            Image(systemName: up ? "chevron.up" : "chevron.down")
                .foregroundColor(disabled ? Color(uiColor: .systemGray3) : color.opacity(0.5))
                .opacity(up && disabled ? 0 : 1)
                .animation(.linear, value: disabled)
            
        })
        .disabled(up ? disabled : false)
    }
    
    
    var dragGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .updating($isDragging) { value, state, _ in
                state = true
            }
            .onChanged { value in 
                let translation = value.translation.height
                let threshold = 40.0
                let adding = translation > 0
                let substracting = !adding
                
                if adding {
                    offset = translation <= threshold ? translation : threshold
                }
                
                if substracting {
                    offset = translation >= -threshold ? translation : -threshold
                }
                
            }
            .onEnded { _ in offset = 0 ; manager.stop() ; if !hasStarted { manager.add() } ; hasStarted = false }
    }
    
    var labelOffset: CGFloat {
        
        if abs(offset) == 40 {return 0}
        if offset > 0 {return offset + 20}
        if offset < 0 && manager.count > 0 {return offset - 20}
        
        return 0
    }
    
    var label: some View {
        Text(manager.count.description)
            .offset(y: labelOffset)
            .font(.title)
            .fontWeight(.bold)
            .animation(.interpolatingSpring(stiffness: 300, damping: 8), value: labelOffset)
    }
}



// Style 
extension StepperView {
    struct ArrowStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .opacity(configuration.isPressed ? 0.5 : 1)
                .scaleEffect(configuration.isPressed ? 0.2 : 1)
        }
    }
}

// Manager
extension StepperView {
    final class Manager: ObservableObject {
        @Published private(set) var count = 0
        
        private var mutationCount = 0
        private var timer: Timer?
        private var cancellables = Set<AnyCancellable>()
        
        func start(adding: Bool, granularity: Double = 0.6) {
            if adding {add()}
            else {substract()}
            
            timer = Timer.scheduledTimer(withTimeInterval: granularity, repeats: true) { _ in 
                if adding { self.add() } 
                else { self.substract() }
                if self.mutationCount == 5 {
                    self.stop()
                    self.start(adding: adding, granularity: 0.1)   
                }
            }
        }
        
        func stop() {
            timer?.invalidate()
            timer = nil
            mutationCount = 0
        }
        
        func add() { count += 1 ; mutationCount += 1 }
        func substract() { if count > 0 { count -= 1} ; mutationCount += 1 }
    }
}
