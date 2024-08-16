import SwiftUI
import SwiftWind

extension CGFloat {
    static let s1 = 4.0
    static let s3 = s1 * 3
    static let s6 = s1 * 6
    static let s8 = s1 * 8
    static let s12 = s1 * 12
}

struct ContentView: View {
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(0..<30) { int in 
                    HStack {
                        Text("Item " + int.description)
                        Spacer()
                    }
                    .padding()
                    .background(Color(uiColor: .systemGray5))
                    .sparkSwipeActions(leading: swipeActions, trailing: swipeActions)
                }
            }
        }
    }
    
    var swipeActions: [SwipeAction] {
        [
            SwipeAction(label: "Pin", systemSymbol: "pin", backgroundColor: .blue, tintColor: .white, action: {print("Pin")}),
            SwipeAction(label: "Edit", systemSymbol: "pencil", backgroundColor: .green, tintColor: .white, action: {print("Edit")}),
            SwipeAction(label: "Trash", systemSymbol: "trash", backgroundColor: .red, tintColor: .white, action: {print("Pin")})
        ]
    }
}

struct SwipeAction: Identifiable, Equatable {
    
    let id: UUID = UUID()
    let label: String?
    let systemSymbol: String
    let action: () -> Void
    let backgroundColor: Color
    let tintColor: Color
    
    init(
        label: String?,
        systemSymbol: String,
        backgroundColor: Color = .black,
        tintColor: Color = .white,
        action: @escaping () -> Void
        
    ) {
        self.label = label
        self.systemSymbol = systemSymbol
        self.action = action
        self.backgroundColor = backgroundColor
        self.tintColor = tintColor
    }
    
    static func == (
        lhs: SwipeAction,
        rhs: SwipeAction
    ) -> Bool {
        lhs.id == rhs.id
    }
}

struct SparkSwipeActionModifier: ViewModifier {
    
    @State var width = CGFloat.zero
    @State var offset = CGFloat.zero
    @State var currentLeadingIndex = Int.zero
    @State var currentTrailingIndex = Int.zero
    @State var shouldHapticFeedback = true
    
    let leading: [SwipeAction]
    let trailing: [SwipeAction]
    
    func body(content: Content) -> some View {
        content
            .background(reader)
            .offset(x:offset)
            .background(leadingGestures)
            .background(trailingGestures)
            .onChange(of: currentLeadingIndex, perform: handleIndexChange(_:))
            .onChange(of: currentTrailingIndex, perform: handleIndexChange(_:))
            .gesture(drag)
    }
    
    var reader: some View {
        GeometryReader { geo in
            Color.clear.onAppear { width = geo.size.width }
        }
    }
    func handleIndexChange(_ index: Int) {
        guard index > 0 else { return }
        //        UIImpactFeedbackGenerator.shared.impactOccurred()
        
#if DEBUG
        print("index changed: \(index)")
#endif
    }
    
    //    @ViewBuilder
    var leadingGestures: some View {
        
        if leading.isEmpty {
            return EmptyView()
        } else {
            
            let initOffset = -.s6 + offset
            let treasholdReached = initOffset > .s3
            
            return ZStack {
                ForEach(0..<leading.count) { index in
                    let isCurrent = index == currentLeadingIndex
                    let item = leading[index]
                    item.backgroundColor
                        .opacity(treasholdReached ? 1 : 0)
                        .opacity(isCurrent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: isCurrent)
                }
                .overlay(leadingGestureLabels, alignment: .leading)
            }
        }
    }
    
    @ViewBuilder
    var trailingGestures: some View {
        
        if trailing.isEmpty {
            EmptyView()
        } else {
            
            
            let initOffset = .s6 + offset
            let treasholdReached = initOffset < -.s3
            
            ZStack {
                ForEach(0..<trailing.count) { index in
                    let isCurrent = index == currentTrailingIndex
                    let item = trailing[index]
                    item.backgroundColor
                        .opacity(treasholdReached ? 1 : 0)
                        .opacity(isCurrent ? 1 : 0)
                        .animation(.easeInOut(duration: 0.3), value: isCurrent)
                }
                .overlay(trailingGestureLabels, alignment: .trailing)
            }
        }
    }
    
    
    var trailingGestureLabels: some View {
        let initOffset = .s6 + offset
        let treasholdReached = initOffset < -.s3
        let item = trailing.getOrNil(index: currentTrailingIndex)
        
        if let item = item {
            return HStack {
                
                if let label =  item.label {
                    Text(label)
                        .opacity(treasholdReached ? 1 : 0)
                }
                
                Image(systemName: item.systemSymbol)
                
            }
            .foregroundColor(item.tintColor)
            .offset(x: treasholdReached ? -.s3 : initOffset)
        } else {
            return EmptyView()
        }
    }
    
    
    var leadingGestureLabels: some View {
        let initOffset = -.s6 + offset
        let treasholdReached = initOffset > .s3
        let item = leading.getOrNil(index: currentLeadingIndex)
        
        if let item = item {
            return HStack {
                
                Image(systemName: item.systemSymbol)
                if let label =  item.label {
                    Text(label)
                        .opacity(treasholdReached ? 0.5 : 0)
                }
            }
            .foregroundColor(item.tintColor)
            .offset(x: treasholdReached ? .s3 : initOffset)
        } else {
            return EmptyView()
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged(handleDragChange)
            .onEnded(handleDragEnd)
    }
    
    func handleDragChange(_ value: DragGesture.Value) {
        
        let horizontalTranslation = value.translation.width
        
        if horizontalTranslation > .s8 && shouldHapticFeedback {
            //            UIImpactFeedbackGenerator.shared.impactOccurred()
            print("Should feedback")
            shouldHapticFeedback = false
        }
        
        if horizontalTranslation < -.s8 && shouldHapticFeedback {
            //            UIImpactFeedbackGenerator.shared.impactOccurred()
            shouldHapticFeedback = false
        }
        
        withAnimation {
            offset = horizontalTranslation
        }
        
        let factor = horizontalTranslation / width
        
        currentLeadingIndex = Int(factor) * leading.count
        
        if horizontalTranslation < 0 {
            currentTrailingIndex = abs(Int(factor)  * trailing.count)
            print(currentTrailingIndex)
        }
    }
    
    func handleDragEnd(_ value: DragGesture.Value) {
        
        let horizontalTranslation = value.translation.width
        
        shouldHapticFeedback = true
        
        if horizontalTranslation >= .s12 {
            leading.getOrNil(index: currentLeadingIndex)?.action()
        }
        
        if horizontalTranslation <= -.s12 {
            trailing.getOrNil(index: currentTrailingIndex)?.action()
        }
        
        resetOffset()
    }
    
    func resetIndex() {
        withAnimation { currentLeadingIndex = 0 }
    }
    
    func resetOffset() {
        withAnimation { offset = 0 }
    }
}


extension View {
    func sparkSwipeActions(
        leading: [SwipeAction] = [],
        trailing: [SwipeAction] = []
    ) -> some View {
        self.modifier(SparkSwipeActionModifier(leading: leading, trailing: trailing))
    }
}


extension Array {
    func getOrNil(index: Int) -> Element? {
        if self.indices.contains(index) {
            return self[index]
        }
        return nil
    }
}
