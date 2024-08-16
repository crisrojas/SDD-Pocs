import SwiftUI

struct ContentView: View {
    
    @State var isOn: Bool = false
    
    var body: some View {
        VStack(spacing: 24) {
            
            Toggle("Native SwiftU/UIKit toggle", isOn: $isOn)
            HStack {
                Text("Custom recreated SwiftUI toggl")
                Spacer()
                CustomToggle(isOn: $isOn)
            }
        }
        .font(.headline)
        .padding(.horizontal, 64)
    }
}

struct CustomToggle: View {
    
    @Binding var isOn: Bool
    let color: Color
    @State private var isPressed: Bool = false
    
    init(
        isOn: Binding<Bool>,
        color: Color = .green
    ) {
        self._isOn = isOn
        self.color = color
    }
    
    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Rectangle()
                .animation(.spring(), value: isOn)
                .foregroundColor(isOn ? color : Color(uiColor: .systemGray4))
                .frame(width: 51)
                .frame(height: 31)
                .cornerRadius(30)
                .overlay(
                    circle,
                    alignment: isOn ? .trailing : .leading
                )
        }
        .buttonStyle(IsPressedDetectStyle{isPressed = $0})
    }
    
    private var circle: some View {
        Rectangle()
            .foregroundColor(.white)
            .frame(width: isPressed ? 32 : 27)
            .frame(height: 27).cornerRadius(999)
            .offset(x: isOn ? -2 : 2)
            .shadow(
                color: .black.opacity(0.2), 
                radius: 8,
                x: -3, 
                y: 3
            )
            .animation(.spring(), value: isOn)
            .animation(.linear(duration: 0.1), value: isPressed)
    }
}


struct IsPressedDetectStyle: ButtonStyle {
    let onPressed: (Bool) -> Void
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .onChange(of: configuration.isPressed) {
                onPressed($0)
            }
    }
}
