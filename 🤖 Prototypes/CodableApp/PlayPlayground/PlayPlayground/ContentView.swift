//
//  ContentView.swift
//  PlayPlayground
//
//  Created by Cristian Felipe Patiño Rojas on 10/04/2024.
//

import SwiftUI

struct ContentView: View {
   
    @State var stacks = [Stack]()
    
    var body: some View {
        List {
            ForEach(stacks) { stack in
                stack.swipeActions(edge: .trailing, allowsFullSwipe: false) {
                   swipeActions(stack)
                }
            }
        }
        .overlay(addStackButton, alignment: .bottom)
        .padding()
    }
    
    @ViewBuilder
    func swipeActions(_ stack: Stack) -> some View {
        Button(action: {changeDirection(of: stack)}) {
            Label("Change direction", systemImage: stack.direction.systemImage)
        }
        .tint(.green)
        
        Button(action: {addButton(to: stack)}) {
            Label("Add Button", systemImage: "plus")
        }
        .tint(.blue)
    }
    
    func addButton(to stack: Stack) {
        if let index = stacks.firstIndex(where: {$0.id == stack.id }){
            stacks[index].content = AnyView(Button(action: {}, label: {"Hello world"}))
        }
    }
    
    func changeDirection(of stack: Stack) {
        if let index = stacks.firstIndex(where: {$0.id == stack.id }){
            stacks[index].direction.changeDirection()
        }
    }
    
    func deleteStack(_ indexSet: IndexSet) { }
    
    var addStackButton: some View {
        Button("Add stack") {
            stacks.append(Stack())
        }
    }
}

extension String: View {
    public var body: Text {Text(self) }
}

infix operator <<: AdditionPrecedence
func << <T> (lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}

enum Direction {
    case horizontal
    case vertical
    
    var systemImage: String {
        switch self {
        case .horizontal: return "arrow.right"
        case .vertical: return "arrow.left"
        }
    }
    
    mutating func changeDirection() {
        switch self {
        case .horizontal: self = .vertical
        case .vertical: self = .horizontal
        }
    }
}

struct Stack: Identifiable, View {
    let id = UUID()
    var direction = Direction.vertical
    var content: AnyView?

    var body: some View {
        switch direction {
        case .horizontal:  HStack { content ?? AnyView(Text("No content")) }
        case .vertical: VStack { content ?? AnyView(Text("No content")) }
        }
    }
}

