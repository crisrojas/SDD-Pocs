import SwiftUI

struct ContentView: View {
    @State private var showSearchModal = false
    @State private var progress = 1.0
    private let iconSide = 54.0
    var body: some View {
        ScrollRepresentable {
            SearchIconView(progress: $progress, side: iconSide).offset(y: -iconSide)
        }
        .onScroll(perform:handleScroll(_:))
        .onLift(perform:handleFingerLift(_:))
        .overlay(searchModal, alignment: .top)
        .animation(.spring(), value: showSearchModal)
        .onTapGesture { showSearchModal = false }
    }
    
    func handleScroll(_ offset: CGPoint) {
        let threshold: Double = -100
        progress = min(offset.y / threshold, 1)
    }
    
    func handleFingerLift(_ offset: CGPoint) {
        let y = offset.y
        if y <= -100 { showSearchModal = true }
    }
    
    var searchModal: some View {
        Text("Search modal goes here")
            .padding()
            .background(Color(uiColor: .systemGray3).cornerRadius(4))
            .scaleEffect(showSearchModal ? 1 : 0)
            .offset(y: 48)
    }
}

struct SearchIconView: View {
    @Binding var progress: Double
    let side: CGFloat
    var body: some View {
        Circle()
            .frame(width: side)
            .frame(height: side)
            .opacity(progress)
            .foregroundColor(progress != 1 ? Color(uiColor: .systemGray3) : .blue)
            .overlay(MagnifyingIcon(progress: progress).offset(x: -2, y: -2))
    }
}


struct MagnifyingIcon: View {
    let progress: Double
    
    private let side: CGFloat = 20
    private let color = Color.white
    var body: some View {
        Circle()
            .trim(from: 0, to: progress)
            .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
            .overlay(magnifyingHandle, alignment: .trailing)
            .rotationEffect(.degrees(-180 + (50 * progress)))
            .frame(width: side)
            .frame(height: side)
    }
    
    var magnifyingHandle: some View {
        Capsule()
            .foregroundColor(color)
            .frame(height: 4)
            .frame(width: progress >= 0.5 ? 10 * progress : 0)
            .offset(x: -20)
        
    }
}


struct ScrollRepresentable<Content: View>: UIViewRepresentable {
    
    func makeCoordinator() -> Coordinator { 
        Coordinator(onLift: onFingerLift, onScroll: onScroll)
    }
    
    func makeUIView(context: Context) -> UIScrollView { 
        uiScrollView.delegate = context.coordinator
        return uiScrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {}
    
    class Coordinator: NSObject, UIScrollViewDelegate {
        
        let onLift: (CGPoint) -> Void
        let onScroll: (CGPoint) -> Void
        
        init(onLift: @escaping (CGPoint) -> Void, onScroll: @escaping (CGPoint) -> Void) {
            self.onLift = onLift
            self.onScroll = onScroll
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) { onScroll(scrollView.contentOffset) }
        func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { onLift(scrollView.contentOffset) }
    }
    
    private let uiScrollView: UIScrollView
    private let onFingerLift: (CGPoint) -> Void
    private let onScroll: (CGPoint) -> Void
    private let content: () -> Content
    
    init
    (onFingerLift: @escaping (CGPoint) -> Void = { _ in }, onScroll: @escaping (CGPoint) -> Void = { _ in},  @ViewBuilder content: @escaping () -> Content) {
        
        self.onFingerLift = onFingerLift
        self.onScroll = onScroll
        self.uiScrollView = UIScrollView()
        self.content = content
        
        let hosting = UIHostingController(rootView: self.content())
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        
        self.uiScrollView.alwaysBounceVertical = true
        self.uiScrollView.addSubview(hosting.view)
        
        self.uiScrollView.addConstraints([
            hosting.view.leadingAnchor.constraint(equalTo: self.uiScrollView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: self.uiScrollView.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: self.uiScrollView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: self.uiScrollView.bottomAnchor),
            hosting.view.widthAnchor.constraint(equalTo: self.uiScrollView.widthAnchor)
        ])
    }
    
    func onLift(perform callback: @escaping (CGPoint) -> Void) -> Self {
        .init(onFingerLift: callback, onScroll: onScroll, content: content)
    }
    
    func onScroll(perform callback: @escaping (CGPoint) -> Void) -> Self {
        .init(onFingerLift: onFingerLift, onScroll: callback, content: content)
    }
}
