//
//  List.Row.swift
//  ThingsKit
//
//  Created by Cristian Felipe Patiño Rojas on 26/08/2023.
//

import SwiftUI


struct Row: View {
    let model: Todo
    let isDragging: Bool
    let isSelected: Bool
    let selectionCount: Int
    let colorHandler: ColorHandler
    let coordinateSpaceName: String
    private var colors: Colors { colorHandler.colors }
    
    // MARK: - Dynamic states
    @Binding var isSelectModeOn: Bool
    @GestureState private var offset = CGFloat.zero
    @State private var swipeDirection: SwipeDirection = .none
    
    enum SwipeDirection {
        case left
        case right
        case none
        
        /// Swipe direction is instantiated with default init, thus default minimumDistance :`DragGesture()`
        /// This prevents the dragGesture to conflict with `ScrollView` gestures.
        /// But that means that when the swipe is triggered, there's already an accumulated translation
        /// which reflects on the offset (when moving the view, instead of smoothly moving it, it applies that acumulated translation offset)
        /// So when user starts gesture, translation is already up (I would say like 10pt) and that causes a small glitch on the gesture
        /// We must apply a correction by substracting those 10pt
        var swipeCorrection: CGFloat {
            let correction = 10.0
            switch self {
            case .right: return -correction
            case .left: return correction
            case .none: return .zero
            }
        }
        init(translation: CGFloat) {
            if translation == 0 { self = .none }
            else if translation > 0 { self = .right }
            else { self = .left }
        }
    }
    
    // MARK: - Actions
    let actions: Actions?
    
    // MARK: - Computed
    private var title: Title {
        Title.init(
            title: model.title,
            colors: colors
        )
    }
    
    private var isSwiping: Bool { offset != .zero }
    private var state: RowState {
        .init(
            isSelected: isSelected,
            isSwiping: isSwiping,
            colors: colors
        )
    }

    // MARK: - Constants
    enum Constants {
        static let height = 44.0
        static let swipeIconOffset = 10.0
        enum CornerRadius {
            static let container = 7.0
            static let row = 6.0
        }
    }

    var body: some View {
        ZStack {
            swipeIconsView
           
            mainStack
                .gesture(dragGesture)
        }
        .padding(.horizontal, 8)
        .frame(height: Constants.height)
        .animation(.linear(duration: 0.1), value: isSelected)
        .onChange(of: isSelected) { _ in
            actions?.generateLightFeedback()
        }
    }
    
    var mainStack: some View {
        HStack {
            
            /// Was applying the "selected" value animation directly on RadioButton Component
            /// But, LazyVStack was retriggering animation on Scroll, so had to put it on the whole ZStack
            /// And remove it from each of this components to prevent weird glitches:
            Image(systemName: "square")
                .resizable()
                .frame(width: 16, height: 16)
                .foregroundColor(isSelected ? colors.iconSelected : colors.icon)
                .animation(nil, value: isSelected)
            Text(title.text)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? title.selectedColor : title.color)
                .animation(nil, value: isSelected)
            Image(systemName: "doc")
                .resizable()
                .frame(width: 10, height: 12)
                .foregroundColor(isSelected ? colors.iconSelected : colors.icon)
                .animation(nil, value: isSelected)
            Spacer()
            RadioButton(
                isDragging: isDragging,
                isSelected: isSelected,
                colors: colors.radioButtonColors
            )
            .opacity(isSelectModeOn ? 1 : 0)
        }
        .padding(.horizontal, 10)
        .frame(height: Constants.height)
        .background(
            state.backgroundColor
                .cornerRadius(Constants.CornerRadius.row)
        )
        .offset(x: offset)
        .animation(offset == 0 ? .linear(duration: 0.2) : nil, value: offset)
        .cornerRadius(Constants.CornerRadius.row)
        .clipShape(RoundedRectangle(cornerRadius: Constants.CornerRadius.row))
        .overlay(border.animation(nil, value: offset))
        .background(boundsGetter)
    }
    
    @ViewBuilder
    var border: some View {
        if isSwiping {
            RoundedRectangle(cornerRadius: Constants.CornerRadius.row)
                .stroke(.black.opacity(0.1), lineWidth: 1)
                .zIndex(10)
        } else {
            EmptyView()
        }
    }

    
    var dragGesture: some Gesture {
        DragGesture()
        // onChanged was causing weird intererences between scrollView & dragGesture
        // use instead updating, which solves those problems
        // more info on that: https://developer.apple.com/forums/thread/123034
            .updating($offset) { value, state, _ in
                
               
                let translation = value.translation.width
                // if swipedirection
                // is the same as init swipedirection then apply regular resistence
                // else apply a lot more
                if .init(translation: translation) == swipeDirection && abs(translation) > 0 {
                    state = makeSwipeOffset(resistence: 10, translation: translation) + swipeDirection.swipeCorrection
                } else {
                    state = makeSwipeOffset(resistence: 3.5, translation: translation)

                }
            }
            .onChanged { value in
                let translation = value.translation.width
                if swipeDirection == .none {
                    swipeDirection = .init(translation: translation)
                }
            }
            .onEnded { value in
                switch swipeDirection {
                case .right:
                    if value.translation.width >= 10 {
                        swipeAction {
                            actions?.leadingAction(model.id)
                        }
                    }
                case .left:
                    if value.translation.width <= 10 {
                        swipeAction {
                            isSelectModeOn = true
                            actions?.trailingAction(model.id)
                        }
                    }
                case .none: break
                }
                swipeDirection = .none
            }
    }
    
    func makeSwipeOffset(resistence multiplier: CGFloat, translation: CGFloat) -> CGFloat {
        let _incrementalWidth = log(abs(translation)) * multiplier
        let incrementalWidth  = translation > 0
        ? _incrementalWidth
        : -_incrementalWidth

        let resistence = abs(translation) < abs(incrementalWidth)
        ? translation
        : incrementalWidth
        
        return resistence
    }
    
    func makeResistenceMultiplier(for distance: CGFloat) -> CGFloat {
        let maxDistance = 50.0
           let minDistance = 0.0
           let initMultiplier = 30.0
           let lastMultiplier = 8.0
           
           // Apply slope function
           let (x1, y1, x2, y2) = (minDistance, initMultiplier, maxDistance, lastMultiplier)
           let slope = (y2 - y1) / (x2 - x1)
           
           // Calculate multiplier
           let clampedDistance = min(max(abs(distance), minDistance), maxDistance)
           let multiplier: CGFloat = initMultiplier + (clampedDistance * slope)
           
           // Limit the multiplier within a range
           let clampedMultiplier = min(max(multiplier, lastMultiplier), initMultiplier)
           
           return clampedMultiplier
    }
    
    /// If is the only item selected, ends selecting mode on swipe.
    /// If selecting mode:
    ///     - Always triggers trailingAction (toggling selection).
    /// If regular mode:
    ///     - Triggers trailing or leading action depending on swipe direction.
    /// - Parameter action: Action to perform on regular mode (not selecting)
    func swipeAction(perform action: () -> Void) {
        if isSelectModeOn {
            if isSelected && selectionCount == 1 {
                isSelectModeOn = false
            } else {
                actions?.trailingAction(model.id)
            }
        } else {
            action()
        }
    }
    var swipeIconsView: some View {
        ZStack {
            WindColor.zinc.c700
            HStack {
                swipeLeadingView
                swipeTrailingView
            }
        }
        .cornerRadius(Constants.CornerRadius.container)
    }
    
    
    var swipeLeadingView: some View {
        (isSelectModeOn
         ? colors.swipeSelecting
         : colors.swipeLeading)
            .overlay(swipeIconLeft, alignment: .leading)
//            .opacity(swipeDirection == .right ? 1 : 0)
    }
    
    var swipeTrailingView: some View {
        (isSelected
         ? colors.swipeSelecting
         : colors.swipeTrailing)
            .overlay(swipeIconRight, alignment: .trailing)
//            .opacity(swipeDirection == .left ? 1 : 0)
    }
    
    
    @ViewBuilder
    var swipeIconLeft: some View {
        if isSelectModeOn { EmptyView() }
        else {
            Image(systemName: "calendar")
                .foregroundColor(.white)
                .offset(x: Constants.swipeIconOffset)
        }
    }
    
    @ViewBuilder
    var swipeIconRight: some View {
        if isSelectModeOn { EmptyView() }
        else {
            Image(systemName: "checklist")
                .foregroundColor(.white)
                .offset(x: -Constants.swipeIconOffset)
        }
    }
    
    var boundsGetter: some View {
        GeometryReader { geometry in
            Rectangle()
                .fill(Color.clear)
                .preference(key: PreferenceKey.self,
                            value: [makePreferences(with: geometry)])
        }
    }
    
    func makePreferences(with proxy: GeometryProxy) -> PreferenceData {
        .init(
            id: model.id,
            bounds: proxy.frame(in: .named(coordinateSpaceName)),
            isSelected: isSelected
        )
    }
}
 
// MARK: - Actions definition
extension Row {
    struct Actions {
        let leadingAction : (UUID) -> Void
        let trailingAction: (UUID) -> Void
        let generateLightFeedback: () -> Void
    }
}

// MARK: - ViewModels
// - State:
extension Row {
    enum RowState {
        case selected(isSwiping: Bool, colors: Row.Colors)
        case unselected(isSwiping: Bool, colors: Row.Colors)
    }
}

extension Row.RowState {
    init(isSelected: Bool, isSwiping: Bool, colors: Row.Colors) {
        if isSelected {
            self = .selected(isSwiping: isSwiping, colors: colors)
        } else {
            self = .unselected(isSwiping: isSwiping, colors: colors)
        }
    }
}

extension Row.RowState {
   
    var backgroundColor: Color {
        switch self {
        case .selected(let isSwiping, let colors):
            return isSwiping ? colors.backgroundSelectedSwiping : colors.backgroundSelected
        case .unselected(let isSwiping, let colors):
            return isSwiping ? colors.backgroundSwiping : colors.background
        }
    }
}

// - Title:
extension Row {
    enum Title {
        case setted(title: String, colors: Row.Colors)
        case unsetted(colors: Row.Colors)
        
        init(title: String?, colors: Row.Colors) {
            if let title = title, !title.isEmpty {
                self = .setted(title: title, colors: colors)
            } else {
                self = .unsetted(colors: colors)
            }
        }
        
        var text: String {
            switch self {
            case .unsetted: return "Nueva tarea"
            case .setted(let title, _): return title
            }
        }
        
        var color: Color {
            switch self {
            case .setted(_, let colors): return colors.text
            case .unsetted(let colors): return colors.textUnsetted
            }
        }
        
        var selectedColor: Color {
            switch self {
            case .setted(_, let colors): return colors.textSelected
            case .unsetted(let colors): return colors.textUnsettedSelected
            }
        }
    }
}

extension Row {
    struct PreferenceData: Equatable {
        let id: UUID
        let bounds: CGRect
        let isSelected: Bool
    }

    struct PreferenceKey: SwiftUI.PreferenceKey {
        typealias Value = [PreferenceData]
        
        static var defaultValue: [PreferenceData] = []
        
        static func reduce(value: inout [PreferenceData], nextValue: () -> [PreferenceData]) {
            value.append(contentsOf: nextValue())
        }
    }
}



// MARK: - Preview
struct Row_Previews: PreviewProvider {
    @State private var selection = Set<UUID>()
    static func preview(_ scheme: ColorScheme) -> some View {
        VStack(spacing: 0) {
            Row(
                model: Todo(id: UUID(), title: ""),
                isDragging: false,
                isSelected: false,
                selectionCount: 0,
                colorHandler: .init(scheme: scheme),
                coordinateSpaceName: "",
                isSelectModeOn: .constant(false),
                actions: nil
            )
            Row(
                model: Todo(id: UUID(), title: "Buy chicken"),
                isDragging: false,
                isSelected: false,
                selectionCount: 0,
                colorHandler: .init(scheme: scheme),
                coordinateSpaceName: "",
                isSelectModeOn: .constant(false),
                actions: nil
            )
            Row(
                model: Todo(id: UUID(), title: nil),
                isDragging: false,
                isSelected: true,
                selectionCount: 0,
                colorHandler: .init(scheme: scheme),
                coordinateSpaceName: "",
                isSelectModeOn: .constant(true),
                actions: nil
            )
            Row(
                model: Todo(id: UUID(), title: "Task title"),
                isDragging: false,
                isSelected: true,
                selectionCount: 0,
                colorHandler: .init(scheme: scheme),
                coordinateSpaceName: "",
                isSelectModeOn: .constant(true),
                actions: nil
            )
        }
        .preferredColorScheme(scheme)
    }
    static var previews: some View {
        Row_Previews.preview(.light)
            .previewLayout(.sizeThatFits)
        Row_Previews.preview(.dark)
            .previewLayout(.sizeThatFits)
        
    }
}
