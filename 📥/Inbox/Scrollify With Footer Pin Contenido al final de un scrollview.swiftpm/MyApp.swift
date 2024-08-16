import SwiftUI

@main
struct MyApp: App { 
    var body: some Scene { 
        WindowGroup { 
            VStack {
                Text("hello")
                Text("hello dkdkdkdkd")
            }.scrollifyWithFooter { 
                Text("hello")
            }
        } 
    }
}


struct ScrollTest: View {
    @State var headerHeight: CGFloat = .zero
    @State var height: CGFloat = .zero
    var body: some View {
//        GeometryReader { geometry in
            ScrollView {
                VStack {
                    
                    Text("Hello, world: \(height)")
                    Text("this is a really long text")
                        .padding(.vertical, 300)
                    
//                    Spacer()
                    
                    footer
                }
                .background(Color.black)
                .overlay(header, alignment: .top)
//                .frame(minHeight: geometry.size.height)
            }
//        }
    }
    
    var footer: some View {
        Text("Footer")
            .frame(maxWidth: .infinity)
            .background(.white)
            .foregroundColor(.black)
        
    }
    
    var header: some View {
        VStack(spacing: 0) {
            Text("header")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.black)
        
        .background(.white)
        .bindHeight(to: $headerHeight)
        
        
    }
}

struct ScrollifyWithFooter<Footer: View>: ViewModifier {
    
    @State var height: CGFloat = .zero
    let footer: () -> Footer
    func body(content: Content) -> some View {
        ScrollView {
            VStack {
                content
                Spacer()
                footer()
            }
            .frame(height: height)
        }
        .bindHeight(to: $height)
    }
}

extension View {
    func scrollifyWithFooter<Footer: View>(footer: @escaping () -> Footer) -> some View {
        self.modifier(ScrollifyWithFooter(footer: footer))
    }
    func geometryfy(closure: @escaping (CGSize) -> Void) -> some View {
        GeometryReader { geo in self.onAppear { closure(geo.size) } }
    }
    
    func bindHeight(to bindingVariable: Binding<CGFloat>) -> some View { 
        self.background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    bindingVariable.wrappedValue = geo.size.height
                }}
        )
    }
    
    func getHeight(callback: @escaping (CGFloat) -> Void) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear.onAppear {
                    callback(geo.size.height)
                }
            }
        )
    }
}
