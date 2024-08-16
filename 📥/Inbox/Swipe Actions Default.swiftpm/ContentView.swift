import SwiftUI
import Combine
import SwiftUItilities
import SwiftWind

struct ContentView: View {
    @State private var model = Array(0...20)
    
    func trailingActions(item: Int) -> [SwipeAction] {
        [
            SwipeAction(label: nil, systemSymbol: "trash", backgroundColor: .red, action: {deleteAction(item: item)}),
            SwipeAction(label: nil, systemSymbol: "trash", backgroundColor: .yellow, action: {deleteAction(item: item)}),
            SwipeAction(label: nil, systemSymbol: "trash", backgroundColor: .indigo, action: {deleteAction(item: item)})
        ]
    }
    
    func deleteAction(item: Int) {
        let index = model.firstIndex(of: item)!
        model.remove(at: index)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                
                ForEach(model, id: \.self) { item in 
                    row(item: item)
                        .swipeActions(
                            leading: trailingActions(item: item), 
                            trailing: trailingActions(item: item)
                        )
                }
            }
        }
    }
    
    func row(item: Int) -> some View {
        HStack {
            Text(item.description)
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .overlay(Divider(), alignment: .bottom)
        .clipShape(Rectangle())
    }
}

struct SwipeActionModifier: ViewModifier {
    
    @State var offset = CGFloat.zero
    
    private let id = UUID()
    let leading: [SwipeAction]
    let trailing: [SwipeAction]
    
    /// Sends current item id to the manager
    /// This allows to collapse all the non-current row actions
    func sink() {
        SwipeManager.shared.$swipingId.dropFirst().sink { swipingId in
            guard let swipingId = swipingId else {
                resetOffset()
                //        SwipeManager.shared.collapse()
                return
            }
            if id != swipingId {
                resetOffset()
            }
        }
        .store(in: &SwipeManager.shared.cancellables)
        
        SwipeManager.shared.$rowIsOpened.dropFirst().sink { isOpened in
            if !isOpened {
                resetOffset()
            }
        }
        .store(in: &SwipeManager.shared.cancellables)
    }
    
    func body(content: Content) -> some View {
        
        content
            .onAppear(perform: sink)
            .background(content)
            .offset(x: offset)
            .background(actions)
            .simultaneousGesture(
                DragGesture()
                    .onChanged(onChangedEvent)
                    .onEnded(onEndedEvent)
            )
    }
    
    var actions: some View {
        DefaultHStack {
            
            leadingActions
            trailingActions
        }
    }
    
    var totalLeadingWidth: CGFloat {
        .swipeActionItemWidth * CGFloat(leading.count)
    }
    
    
    func actionView(_ action: SwipeAction, width: CGFloat) -> some View {
        let iconWidth = CGFloat.s4
        let iconOffset = (.swipeActionItemWidth - iconWidth) / 2
        return action.backgroundColor
            .overlay(
                Image(systemName: "action.systemSymbol")
                    .resizable()
                    .foregroundColor(.red)
                    .size(iconWidth)
                    .offset(x:-iconOffset)
                ,
                alignment: .trailing
            )
    }
    
    var leadingActions: some View {
        ZStack(alignment: .leading) {
            ForEach(leading.reversed().indices, id: \.self) { index in
                let action = leading.reversed()[index]
                let realIndex = leading.firstIndex(of: action)!
                let factor = CGFloat(realIndex + 1)
                let width = .swipeActionItemWidth * factor
                let dynamicWidth = offset / CGFloat(leading.count) * factor
                let maxWidth = dynamicWidth < width ? dynamicWidth : width
                let shouldExpand = offset > totalLeadingWidth && realIndex == 0
                
                let callback = {
                    action.action()
                    resetOffset()
                }
                
                SwipeActionView(
                    width: maxWidth,
                    action: action,
                    callback: callback
                )
                .width(shouldExpand ? totalLeadingWidth : maxWidth)
            }
        }
        .alignX(.leading)
        .displayIf(!leading.isEmpty)
    }
    
    var trailingActions: some View {
        ZStack(alignment: .leading) {
            ForEach(trailing.reversed().indices, id: \.self) { index in
                let action = trailing.reversed()[index]
                let realIndex = trailing.firstIndex(of: action)!
                let factor = CGFloat(realIndex + 1)
                let width = .swipeActionItemWidth * factor
                let dynamicWidth = offset / CGFloat(trailing.count) * factor
                let maxWidth = dynamicWidth < width ? dynamicWidth : width
                let shouldExpand = offset > totalLeadingWidth && realIndex == 0
                
                let callback = {
                    action.action()
                    resetOffset()
                }
//                
//                SwipeActionView(
//                    width: maxWidth,
//                    action: action,
//                    callback: callback
//                )
//                .width(shouldExpand ? totalLeadingWidth : maxWidth)
            }
        }
        .alignX(.trailing)
        .displayIf(!trailing.isEmpty)
    }
    
    func resetOffset() {
        withAnimation(.easeOut(duration: 0.45)) { offset = .zero }
    }
    
    var isOpened: Bool { offset >= totalLeadingWidth }
    
    @State private var shouldHapticFeedback: Bool = true
    @State private var shouldSendId: Bool = true
    
    func onChangedEvent(_ value: DragGesture.Value) {
        
        let width = value.translation.width
        if shouldSendId {
            SwipeManager.shared.swipingId = id
            shouldSendId = false
        }
        guard !isOpened else {
            //      print("isOpened")
            if offset > totalLeadingWidth && shouldHapticFeedback {
//                NotificationFeedback.shared.notificationOccurred(.success)
                shouldHapticFeedback = false
            }
            let maxAddOffset = width < .s2 ? width : .s2
            withAnimation { offset = totalLeadingWidth + maxAddOffset }
            
            
            return
        }
        
        withAnimation { offset = width }
    }
    
    func onEndedEvent(_ value: DragGesture.Value) {
        
        let width = value.translation.width
        
        shouldHapticFeedback = true
        shouldSendId = true
        
        guard !leading.isEmpty else { return }
        
        if isOpened && (offset + width) > totalLeadingWidth {
            leading.first?.action()
        }
        
        if width > .s28 && width < totalLeadingWidth {
            withAnimation {
                offset = totalLeadingWidth
                SwipeManager.shared.rowIsOpened = true
            }
        } else if width > totalLeadingWidth {
            leading.first?.action()
            resetOffset()
            SwipeManager.shared.rowIsOpened = false
        } else {
            resetOffset()
            SwipeManager.shared.rowIsOpened = false
        }
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

extension CGFloat { static let swipeActionItemWidth = CGFloat.s1 * 18 }

extension View {
    
    func swipeActions(
        leading: [SwipeAction] = [],
        trailing: [SwipeAction] = []
    ) -> some View {
        
        self.modifier(
            SwipeActionModifier(
                leading: leading,
                trailing: trailing
            )
        )
    }
}

struct SwipeActionView: View {
    
    @State var width: CGFloat
    let action: SwipeAction
    let callback: () -> Void
    private var iconOffset: CGFloat { (.swipeActionItemWidth - width) / 2 }
    
    var body: some View {
        return Button { 
            callback()
        } label: { 
            action.backgroundColor
                .overlay(
                    Image(systemName: action.systemSymbol)
                        .foregroundColor(action.tintColor)
                        .background(reader)
                        .offset(x: -iconOffset)
                    ,
                    alignment: .trailing
                )
        }
            .buttonStyle(.plain)
    }
    
    var reader: some View {
        GeometryReader { geo in
            Color.clear.onAppear {
                width = geo.size.width
            }
        }
    }
}


import Combine
import SwiftUI

final class SwipeManager: ObservableObject {
    
    @Published var swipingId: UUID?
    @Published var rowIsOpened: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    
    static let shared = SwipeManager()
    private init() {}
    
    func collapse() {
        rowIsOpened = false
    }
}
