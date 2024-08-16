import SwiftUI

struct ContentView: View {
    
    @State private var showPanel = false
    @Namespace private var namespace
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(addButton(isShown: !showPanel), alignment: .bottomTrailing)
        .overlay(addPanel)
        .animation(.linear(duration: transitionDuration), value: showPanel)
    }
    
    private let transitionDuration = 0.2
    
    func didPressAddButton() {showPanel.toggle()}
    
    @State private var panelAppeared = false
    @State private var expanded = false
    @ViewBuilder var addPanel: some View {
        if showPanel {
           ZStack {
               Color.black.opacity(0.3).onTapGesture { panelAppeared = false ; expanded = false ; showPanel = false }
               VStack {
                   
                   if !panelAppeared {
                       Image(systemName: "plus")
                           .resizable()
                           .frame(width: 24)
                           .frame(height: 24)
                           .fontWeight(.black)
                           .onAppear { 
                               DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration + 0.05) {
                                   panelAppeared = true
                               }
                               
                           }
                   } else {
                       Text("Modal content")
                   }
               }
               .onAppear { 
                   DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                       withAnimation(.linear) { 
                           expanded = true
                       }
                   }
               }
               .frame(maxWidth: panelAppeared ? .infinity : 64, maxHeight: panelAppeared ? .infinity - 120 : 64)
               .background((expanded ? Color(uiColor: .systemGray4) : Color.accentColor).cornerRadius(12))
               .padding(.vertical, 160)
               .padding(.horizontal, 8)
               .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 0)
               .matchedGeometryEffect(id: "background", in: namespace, properties: .position, anchor: .center, isSource: false)
               .animation(.interpolatingSpring(stiffness: 300, damping: 12), value: panelAppeared)

           }
        } 
    }
    
    @ViewBuilder func addButton(isShown: Bool) -> some View {
        if isShown {
            Button(action:didPressAddButton, label: {
                VStack {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 24)
                        .frame(height: 24)
                        .fontWeight(.black)
                }
                .padding(12)
                .background(Color.accentColor.cornerRadius(999))
                .padding()
                .matchedGeometryEffect(id: "background", in: namespace, properties: .position, anchor: .center, isSource: true)
            })
            .buttonStyle(ScaleEffectStyle())
        }
    }
}

struct ScaleEffectStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.3 : 1)
            .animation(.linear(duration: 0.1), value: configuration.isPressed)
    }
}


extension View {
    func buttonify(performing action: @escaping () -> Void) -> some View {
        Button(action: action, label: {self})
    }
}
