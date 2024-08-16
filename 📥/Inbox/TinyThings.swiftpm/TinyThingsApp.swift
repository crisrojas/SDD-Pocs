import SwiftUI

@main
struct TinyThings: App {
    var body: some Scene {
        WindowGroup {
            Todos()
        }
    }
}

let initialTodos = [
    Todo("Groceries"),
    Todo("Team Standup"),
    Todo("Check Email"),
    Todo("Sprint Planning"),
    Todo("Water Plants")
]

struct Todos: AppView {
    
    @State var todos = initialTodos
    
    var body: some View {
        VStack {
            Header()
            List()
            Spacer()
        }
        .animation(.linear, value: todos)
        .foregroundColor(.white)
        .background(.black)
    }
    
    func toggleCheck(_ id: UUID) {
        todos[id]?.isChecked.toggle()
    }
}

extension Todos {
    @ViewBuilder
    func Header() -> some View {
        Image(systemName: "star.fill")
            .resizable()
            .side(.s9)
            .foregroundColor(.yellow)
            .top(.s8)
        
        Text("Today")
            .font(.largeTitle)
            .fontWeight(.bold)
    }
    
    func List() -> some View {
        LazyVStack(spacing: .s4) {
            ForEach(todos.unchecked()) { todo in
                Row(todo) * {
                    $0.checkItem = toggleCheck
                }
            }
        }
        .padding(.s6)
    }
}

extension Todos {
    struct Row: AppView {
        
        @State var checkedState: Bool = false
        var checkItem: UUID.Void?
        let model: Todo
        
        init(_ m: Todo) {
            model = m
            _checkedState = .init(initialValue: m.isChecked)
        }
        
        private var base: WindColor { .zinc }
        private var complement: WindColor { .blue }
        
        var body: some View {
            Button(action: {checkedState.toggle()}) {
                HStack(spacing: .s4) {
                    checkbox
                    
                    model.description.body
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .foregroundColor(base.c200)
                .padding(.s6)
                .background(bg)
            }
            .onChange(of: checkedState) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    checkItem?(model.id)
                }
            }
        }
        
        var bg: some View {
            base.c800
                .overlay(
                    complement.c400
                        .opacity(0.3)
                        .maxWidth(checkedState ? .infinity : 0)
                    , alignment: .leading)
                .cornerRadius(.s4)
        }
        
        var checkbox: some View {
            let fg = checkedState
            ? complement.c400
            : base.c500
            let sb = checkedState
            ? "square.fill"
            : "square"
            return Image(systemName: sb)
                .resizable()
                .side(.s6)
                .foregroundColor(fg)
                .overlay(checkmark)
                .animation(.linear, value: checkedState)
        }
        
        @ViewBuilder
        var checkmark: some View {
            if checkedState {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                
            } else {
                EmptyView()
            }
        }
    }
}
