import SwiftUI

typealias Closure = () -> Void
extension View {
    func onTap(perform action: @escaping Closure) -> some View { 
        Button(action: action, label: {self})
    }
}

struct ContentView: View {
    
    @State private var count = 0
    @State private var offset = 0.0
    
    private let side = 140.0
    
    var body: some View {
        VStack(spacing: 28) {
            
            chevron(up: true)
                .zIndex(1)
                .onTap { 
                    if selection > model.min() ?? 0 { 
                        selection -= 1
                    }
                }
            
            Rectangle()
                .frame(width: side)
                .frame(height: side)
                .cornerRadius(40)
                .overlay(label)
                .shadow(color: .red500.opacity(0.5), radius: 30, x: 0, y: 20)
                .offset(y: offset)
                .gesture(dragGesture)
                .animation(.linear, value: offset)
                .zIndex(2)
            
            chevron(up: false)
                .zIndex(1)
                .onTap {
                    if selection == model.max(), let last = model.last { 
                        model.append(last + 1)
                    }
                    selection += 1 
                }
            
            Button("Restart") {
                selection = 0
            }
        }
        .foregroundColor(.red500)
         .frame(maxWidth: .infinity, maxHeight: .infinity)
         .background(WindColor.pink.c50)
         .animation(.interpolatingSpring(stiffness: 300, damping: 10), value: selection)
         .onChange(of: offset) { newValue in 
             print(newValue)
         }
         .onChange(of: selection) { newValue in 
             if newValue == model.last {
                 
             }
         }
    }
    
    private let threshold = 100.0
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in 
                let heigth = value.translation.height
                let adding = heigth > 0
                let substracting = !adding
                
                if adding {}
                if substracting {}
                
                if abs(heigth) <= threshold {
                    offset = heigth
                }
            }
            .onEnded { value in 
                offset = 0
            }
//            .updating($offset) { value, state, _ in
//               
//                let heigth = value.translation.height
//                if abs(heigth) <= threshold {
//                     state = value.translation.height
//                }
//            }
            
    }
    
    @State private var model = [0]
    @State private var selection = 0
    private var label: some View {
        TabView(selection: $selection) {
            ForEach(model, id: \.self) { int in
                Text(int.description)
                .rotationEffect(.degrees(-90))
                .tag(int)
            }
        }
        .disabled(true)
        .font(.custom("Avenir", size: 64))
        .fontWeight(.bold)
        .rotationEffect(.degrees(90))
        .foregroundColor(.white)
        .tabViewStyle(.page(indexDisplayMode: .never)) 
    }
    
    private func chevron(up: Bool) -> some View {
        Image(systemName: up ? "chevron.up" : "chevron.down")
            .resizable()
            .frame(width: 40)
            .frame(height: 24)
            .fontWeight(.black)
            .opacity(0.2)
            
    }
}

extension View {
    func side(_ value: CGFloat) -> some View {
        self.frame(width: value, height: value)
    }
}
