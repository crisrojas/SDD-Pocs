//
//  SwiftUIView.swift
//  
//
//  Created by Cristian Felipe Patiño Rojas on 26/08/2023.
//

import SwiftUI

extension ListView {
    enum Constants {
        static let scrollThreshold = 80.0
        static let coordinateSpaceName = "ListView"
    }
}

extension ListView {
    struct GestureDetails: Equatable {
        let isDragging: Bool
        let translation: CGFloat
        
        init(isDragging: Bool = false, translation: CGFloat = .zero) {
            self.isDragging  = isDragging
            self.translation = translation
        }
    }
}

struct ListView: View {
    @State private var isSelectModeOn: Bool = false
    @State private var selection =  Set<UUID>()
    @Environment(\.colorScheme) var systemColorScheme
    @State private var preferredColorScheme: ColorScheme?
    @State private var drag = GestureDetails()
    @State private var rowsData: [Row.PreferenceData] = []
    private var colorScheme: ColorScheme {
        preferredColorScheme ?? systemColorScheme
    }
    
    let model: [Todo]
    
    var background: Color {
        switch colorScheme {
        case .light: return .white
        case .dark: return .black
        default: fatalError("Not implemented")
        }
    }
    
    var body: some View {content}
    
    private var content: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                switchSchemeButton
                LazyVStack(spacing: 0) {
                    ForEach(0...model.count - 1, id: \.self) { index in
                        Row(
                            model: model[index],
                            isDragging: drag.isDragging,
                            isSelected: selection.contains(model[index].id),
                            selectionCount: selection.count,
                            colorHandler: .init(scheme: colorScheme),
                            coordinateSpaceName: Constants.coordinateSpaceName,
                            isSelectModeOn: $isSelectModeOn,
                            actions: rowActions
                        )
                        .id(index)
                    }
                    .animation(.linear, value: isSelectModeOn)
                }
                .padding(.top)
                .onChange(of: isSelectModeOn) { isSelecting in
                    if !isSelecting {
                        selection = []
                    }
                }
            }
            .background(background)
            .preferredColorScheme(colorScheme)
            .overlay(alignment: .top) {
                background
                    .ignoresSafeArea(edges: .top)
                    .frame(height: 0)
            }
            .onPreferenceChange(Row.PreferenceKey.self) {
                rowsData = $0
            }
            .overlay(dragView(), alignment: .trailing)
            .coordinateSpace(name: Constants.coordinateSpaceName)
        }
    }
 
    func dragView() -> some View {
        Rectangle()
            .foregroundColor(Color.green.opacity(0.5))
            .frame(width: 60)
            .gesture(dragGesture())
            .opacity(isSelectModeOn ? 1 : 0)
    }
    
    @State private var dragToSelectIntent: DragToSelectIntent?
    
    enum DragToSelectIntent {
        case select
        case deselect
        
        init(shoudSelect: Bool) {
            self = shoudSelect ? .select : .deselect
        }
        
        var shouldSelect: Bool {
            switch self {
            case .select: return true
            case .deselect: return false
            }
        }
    }
    
    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                drag = .init(isDragging: true, translation: value.translation.height)
                if let row = rowsData.first(where: {$0.bounds.contains(value.location)}) {
                    let index = model.firstIndex(where: { $0.id == row.id })
                    if let dragToSelectIntent = dragToSelectIntent {
                        toggleSelection(of: row.id, select: dragToSelectIntent.shouldSelect)
                    } else {
                        dragToSelectIntent = .init(shoudSelect: !row.isSelected)
                        toggleSelection(of: row.id, select: dragToSelectIntent!.shouldSelect)
                    }
                }
            }
            .onEnded { _ in
                drag = .init()
                dragToSelectIntent = nil
            }
//            .updating($gesture) { value, state, _ in
//                state = .init(
//                    isDragging: true,
//                    translation: value.translation.height
//                )
//            }
    }
    
    func coordinatesGetter(_ id: Int) -> some View {
        GeometryReader { proxy in
            Color.clear.onAppear {
//                rowCoordinates.append(.init(id: id, location: proxy.frame(in: .named(Constants.scrollCoordinateSpaceName))))
            }
        }
    }
    
    
    var switchSchemeButton: some View {
        Button(action: {
            if preferredColorScheme == nil {
                preferredColorScheme = .light
            } else if preferredColorScheme == .light {
                preferredColorScheme = .dark
            } else {
                preferredColorScheme = .light
            }
        }, label: {Text("Switch color scheme")})
    }
    
    
    var rowActions: Row.Actions {
        .init(
            leadingAction: { print($0) },
            trailingAction: toggleSelection(of:),
            generateLightFeedback: FeedbackManager.shared.generateLightFeedback
        )
    }
    
    func toggleSelection(of item: UUID, select: Bool) {
        if select { selection.insert(item) }
        else { selection.remove(item) }
    }
    
    func toggleSelection(of item: UUID) {
        if let _ = selection.remove(item) {return}
        selection.insert(item)
    }
}


struct ListView_Previews: PreviewProvider {
    static let model: [Todo] = Array(0...40).map {
        .init(id: UUID(), title: $0 % 2 == 0 ? nil : "Comprar pollo")
    }
    
    static var previews: some View {
        ListView(model: ListView_Previews.model)
            .previewLayout(.sizeThatFits)
        ListView(model: ListView_Previews.model)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
