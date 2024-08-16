//
//  ContentView.swift
//  Speak
//
//  Created by Cristian Felipe Patiño Rojas on 19/04/2024.
//

import SwiftUI

extension Editor {
    struct Text: Identifiable, Equatable, View {
        let id = UUID()
        var value: String
        
        var body: some View {value}
    }
}

extension [Editor.Text] {
    func flat() -> String {
        self.dropFirst().reduce(self[0].value) {
            $0 + " " + $1.value
        }
    }
}

func * <T> (lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}

extension Array where Element: Identifiable {
    subscript(id: Element.ID) -> Element? {
        get { first { $0.id == id } }
        set(newValue) {
            if let index = firstIndex(where: { $0.id == id }) {
                if let newValue = newValue {
                    self[index] = newValue
                } else {
                    remove(at: index)
                }
            } else if let newValue = newValue {
                append(newValue)
            }
        }
    }
}


extension View {
    @ViewBuilder
    func `if`(_ condition: Bool, transform: (Self) -> some View) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension View {
    func onTap(perform action: @escaping () -> Void) -> Button<Self> {
        Button(action: action, label: {self})
    }
}

extension [Character] {
    func split() -> [Editor.Text] {
        self.map { .init(value: String($0))}
    }
}

struct CharacterEditor: View {
    @State var components: [Editor.Text]
    @State var selected: UUID = UUID()
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(components) { item in
                    item.border(selected == item.id ? .red : .clear)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(buttons, alignment: .bottom)
        .onAppear {
            selected = components.first?.id ?? UUID()
        }
    }
    
    var buttons: some View {
        HStack {
            Spacer()
            Image(systemName: "chevron.backward")
                .onTap {
                    selected = previeous()
                }
            Spacer()
            Image(systemName: "chevron.forward")
                .onTap { selected = next() }
            Spacer()
        }
    }
    
    func previeous() -> UUID {
        guard let index = components.firstIndex(where: {$0.id == selected}) else { return components.last?.id ?? .init() }
        guard components.indices.contains(index - 1) else { return components.last?.id ?? .init() }
        return components[index - 1].id
    }
    
    func next() -> UUID {
        guard let index = components.firstIndex(where: {$0.id == selected}) else { return components.first?.id ?? .init() }
        guard components.indices.contains(index + 1) else { return components.first?.id ?? .init() }
        return components[index + 1].id
    }
}

struct EditorScroll: View {
    @Binding var text: String
    @State var components: [Editor.Text]
    @State var selected: UUID = UUID()
    
    var selectedComponets: [Editor.Text] {
        let value = components.first(where: {selected == $0.id})?.value ?? ""
        return value.map { Editor.Text(value: String($0)) }
    }
  
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                ForEach(components) { item in
                    item
                        .onTap(perform: {selected = item.id})
                        .buttonStyle(.plain)
                        .border(selected == item.id ? .red : .clear)
                }
            }
            
//            NavigationLink("Edit") {
//                
//                CharacterEditor(components: selectedComponets)
//            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(buttons, alignment: .bottom)
        .onAppear {
            selected = components.first?.id ?? UUID()
        }
    }
    
    var buttons: some View {
        HStack {
            Spacer()
            Image(systemName: "chevron.backward")
                .onTap {
                    selected = previeous()
                }
            Spacer()
            Image(systemName: "chevron.forward")
                .onTap { selected = next() }
            Spacer()
        }
    }
    
    func previeous() -> UUID {
        guard let index = components.firstIndex(where: {$0.id == selected}) else { return components.last?.id ?? .init() }
        guard components.indices.contains(index - 1) else { return components.last?.id ?? .init() }
        return components[index - 1].id
    }
    
    func next() -> UUID {
        guard let index = components.firstIndex(where: {$0.id == selected}) else { return components.first?.id ?? .init() }
        guard components.indices.contains(index + 1) else { return components.first?.id ?? .init() }
        return components[index + 1].id
    }
    
    var tab: some View {
        TabView(selection: $selected) {
            ForEach(components) { item in
                item.tag(item.id)
                
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
        .tabViewStyle(.page)
        .background(.red)
    }
    
    var selectGauge: some View {
//        Color.clear
        Color.gray
            .frame(width: 24)
            .frame(height: 400)
            .background(.thickMaterial)
            .cornerRadius(12)
            .offset(x: -12)
            .gesture(drag)
            
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged {
                print($0)
            }
            .onEnded { _ in  }
    }
    
}


struct Editor: View {
    
    @Environment(\.dismiss) var dismiss
    @Binding var text: String
    @State var components: [Text]
    
    var body: some View {
        VStack {
            TabView {
                ForEach(components) { item in
                    edit(item)
                }
            }
            .tabViewStyle(.page)
            .animation(.easeInOut, value: components)
            Button("save") {
                text = components.flat()
               // dismiss()
            }
        }
    }
    
    @State var editing: UUID?
    func edit(_ text: Text) -> some View {
        VStack(spacing: 24) {
            TextField(text.value, text: binding(text))
                .disabled(editing != text.id)
            Button(action: {
                editing = text.id
            }, label: {Image(systemName: "pencil")})
            
            Button(action: {
                components[text.id] = nil
            }, label: {Image(systemName: "trash")})
        }
    }
    
    func binding(_ item: Text) -> Binding<String> {
        let i = components.firstIndex(of: item)!
        return .init(
            get: { components[i].value },
            set: { components[i].value = $0 }
        )
    }
}

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @State var text = "This is an example test with an tpeng error"
    @State var isActive = true
    var body: some View {
        NavigationView {
            VStack {
                Text(text)
                
                NavigationLink(destination: EditorScroll(text: $text, components: text.split()), isActive: $isActive) {
                    Image(systemName: "pencil")
                }
            }
            .padding()
        }
    }
    
    func pop() {
        
    }
}

extension String: View { public var body: Text {Text(self)} }
extension String {
    func split() -> [Editor.Text] {
        self.components(separatedBy: " ").map {.init(value: $0)}
    }
}
