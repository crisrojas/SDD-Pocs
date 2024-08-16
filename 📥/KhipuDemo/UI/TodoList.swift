//
//  TodoList.swift
//  UI
//
//  Created by Cristian Felipe Patiño Rojas on 07/04/2023.
//

import SwiftUI
import Models

public typealias TodoListClient = (
    add: (ToDo) -> (),
    delete: (ToDo) -> (),
    update: (ToDo, ToDo.Change) -> (),
    edit: (Bool) -> ()
)

public struct TodoList: View {
    
    let todos: [ToDo]
    let editing: Bool
    let client: TodoListClient?
    
    public init(todos: [ToDo], editing: Bool, client: TodoListClient? = nil) {
        self.todos   = todos
        self.editing = editing
        self.client  = client
    }
    
    var editMode: Binding<EditMode> {
        Binding {
            editing.asEditMode
        } set: { editMode, _ in
            client?.edit(editMode.editing)
        }
    }
    
    public var body: some View {
        NavigationView {
            List {
                ForEach(todos) { item in
                    HStack {
                        Image(systemName: item.done ? "checkmark.circle" : "circle")
                            .buttonify {
                                client?.update(item, .toggle)
                            }
                        Text(item.fullTitle)
                    }
                }
                .onDelete(perform: delete)
            }
            .animation(.linear, value: todos)
            .animation(.linear, value: editing)
            .environment(\.editMode, editMode)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        client?.edit(!editing)
                    } label: {
                        Text(editing ? "Done" : "Edit")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        client?.add(ToDo())
                    } label: {
                        Image(systemName: "plus")
                    }

                }
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        offsets.forEach { index in
            let todo = todos[index]
            client?.delete(todo)
        }
    }
}


// MARK: - Helpers

extension ToDo {
    var fullTitle: String {
        title.isEmpty
        ? "New item"
        : title
    }
}

extension EditMode {
    var editing: Bool {self == .active}
}

extension Bool {
    var asEditMode: EditMode {self ? .active : .inactive}
}


public extension View {
    func buttonify(performing action: @escaping () -> ()) -> some View {
        Button(action: action, label: {self})
    }
}
