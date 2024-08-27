//
//  _swiftuitilities.swift
//  Movies
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import SwiftUI

// MARK: - Stacks
// Remove default spacing of freaking SwiftUI on stacks...
struct HStack<Content: View>: View {
    var alignment: VerticalAlignment = .center
    var spacing: CGFloat = 0
    @ViewBuilder var content: () -> Content
    var body: some View {
        SwiftUI.HStack(
            alignment: alignment,
            spacing: spacing,
            content: content
        )
    }
}

// Remove default spacing of freaking SwiftUI on stacks...
struct VStack<Content: View>: View {
    var alignment: HorizontalAlignment = .center
    var spacing: CGFloat = 0
    @ViewBuilder var content: () -> Content
    var body: some View {
        SwiftUI.VStack(
            alignment: alignment,
            spacing: spacing,
            content: content
        )
    }
}


// MARK: - View utilities
extension View {
    
    // padding
    
    func top(_ value: CGFloat) -> some View {
        self.padding(.top, value)
    }
    
    func vertical(_ value: CGFloat) -> some View {
        self.padding(.vertical, value)
    }
    
    func horizontal(_ value: CGFloat) -> some View {
        self.padding(.horizontal, value)
    }
    
    func bottom(_ value: CGFloat) -> some View {
        self.padding(.bottom, value)
    }
    
    func leading(_ value: CGFloat) -> some View {
        self.padding(.leading, value)
    }
    
    func trailing(_ value: CGFloat) -> some View {
        self.padding(.trailing, value)
    }
    
    
    // frame
    func size(_ value: CGFloat?) -> some View {
        self.frame(width: value, height: value)
    }
    
    func width(_ value: CGFloat?) -> some View {
        self.frame(width: value)
    }
    
    func height(_ value: CGFloat?) -> some View {
        self.frame(height: value)
    }
    
    
    /// Returns a view taking the whole screen width & height available.
    /// Ignores safe area
    func fullScreen() -> some View {
        self
            .frame(width: UIScreen.main.bounds.size.width)
            .frame(height: UIScreen.main.bounds.size.height)
            .edgesIgnoringSafeArea(.all)
    }
    
    // wrappers
    func scrollify(_ axis: Axis.Set = .vertical) -> ScrollView<Self> {
        
        ScrollView(axis, showsIndicators: false) {
            self
        }
    }
    
    func scrollify(_ axis: Axis.Set = .vertical, onScroll: @escaping (CGFloat) -> Void) -> some View {
        ScrollView(axis, showsIndicators: false) {
            self.background(
                GeometryReader {
                    Color.clear.preference(
                        key: ViewOffsetKey.self,
                        value: -$0.frame(in: .named("scroll")).origin.y
                    )
                }
            )
            .onPreferenceChange(ViewOffsetKey.self) { offset in
                onScroll(offset)
            }
        }
        .coordinateSpace(name: "scroll")
    }
    
    func navigationify() ->  NavigationView<Self> {
        NavigationView { self }
    }
    
    func onTap<D: View>(navigateTo destination: () -> D) -> some View {
        NavigationLink(destination: destination()) {
            self
        }
    }
    
    func onTap<D: View>(navigateTo destination: D) -> some View {
        NavigationLink(destination: destination) {
            self
        }
    }
    
    func onTap(perform: @escaping () -> ()) -> some View {
        Button {
            perform()
        } label: {
            self
        }
    }
    
    // alignment
    
    func alignX(_ alignment: HorizontalAlignment) -> some View  {
        
        HStack {
            switch alignment {
            case .leading:
                self
                Spacer()
            case .center:
                Spacer()
                self
                Spacer()
            case .trailing:
                Spacer()
                self
            default:
                self
            }
        }
    }
}

extension View {
    @ViewBuilder
    func isHidden(_ condition: Bool) -> some View {
        if condition { EmptyView() }
        else { self }
    }
    
    @ViewBuilder
    func isShown(_ condition: Bool) -> some View {
        if condition { self }
        else { EmptyView() }
    }
}


extension View {
    func getProxy(completion: @escaping (GeometryProxy) -> Void) -> some View {
        self.background(
            GeometryReader { proxy in
                Color.clear.onAppear {
                    DispatchQueue.main.async {
                        completion(proxy)
                    }
                }
            }
        )
    }
}

extension View {
    // Optional so we can conditionally use it
    func statusBarBackground<Background: View>(_ background: Background) -> some View {
        self.overlay(alignment: .top) {
            Color.clear
                .background(background)
                .ignoresSafeArea(edges: .top)
                .height(0)
        }
    }
    
    @ViewBuilder
    func statusBarBackground(_ background: Material?) -> some View {
            self.overlay(alignment: .top) {
                Color.clear
                    .background(background ?? .thinMaterial)
                    .opacity(background != nil ? 1 : 0)
                    .ignoresSafeArea(edges: .top)
                    .height(0)
            
        }
    }
}
extension View {
    @ViewBuilder
    func modify(@ViewBuilder _ transform: (Self) -> (some View)) -> some View {
        transform(self)
    }
    
    
    
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}


struct PressTrackerStyle: ButtonStyle {
    let onPress: (Bool) -> Void
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed, perform: onPress)
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}


#if DEBUG
extension View {
    func text(_ text: Any, alignment: Alignment = .center) -> some View {
        self.overlay(Text("\(text)").background(.black), alignment: alignment)
    }
    
    func text(_ texts: Any..., alignment: Alignment = .center) -> some View {
        self.overlay(
            VStack {
                ForEach(texts.map { "\($0)" }, id: \.self) {
                    Text($0)
                }
            }
            .background(.black)
            , alignment: alignment
        )
    }
}
#endif
