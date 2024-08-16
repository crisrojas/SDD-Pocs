//
//  CodableDatabaseApp.swift
//  CodableDatabase
//
//  Created by Cristian Felipe Patiño Rojas on 22/12/2023.
//

import SwiftUI
import Core

struct Todo: Persistable, Mappable, Equatable {
    let id: UUID
    var title: String
    var isChecked: Bool
}

extension Todo {
    init(title t: String) {
        id = UUID()
        title = t
        isChecked = false
    }
}


@main
struct CodableDatabaseApp: App {
   @StateObject var database = Database(path: "prod")
    var body: some Scene {
        WindowGroup {
            TodoList(todos: database.read().sort(\.title, \.isChecked))
                .inject(\.crud, todoCrud)
        }
    }
    
    var todoCrud: Actions<Todo> {
        .init()
            .inject(\.upsert, database.upsert)
            .inject(\.delete, database.delete)
    }
}

// upsert delete
final class Actions<T>: KeyPathMutable {
    var upsert: Throwable<Todo>?
    var delete: Completion<Todo>?
}


struct TodoList: AppView {
    let todos: [Todo]
    var crud: Actions<Todo>?
    @State var showingCreate = false
    var body: some View {
        NavigationView {
            if todos.isEmpty {
                VStack {
                    Text("No todos added yet")
                    Button("Start adding") {
                        showingCreate = true
                    }
                    .sheet(isPresented: $showingCreate) {
                        createScreen
                    }
                }
            } else {
                List {
                    ForEach(todos) { item in
                        HStack {
                            item.title
                            Spacer()
                            Button {
                                try? crud?.upsert?(item.map {$0.isChecked = !$0.isChecked })
                            } label: {
                                Image(systemName: item.isChecked ? "checkmark" : "")
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { index in
                            let todo = todos[index]
                            crud?.delete?(todo)
                        }
                    }
                   
                }
                .animation(.linear, value: todos)
                .sheet(isPresented: $showingCreate) {
                    createScreen
                }
                .toolbar {
                    Button(action: {showingCreate = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
    
    var createScreen: Create {
        Create().inject(\.save, crud?.upsert)
    }
}

extension String: View {
    public var body: Text {
        Text(self)
    }
}

extension TodoList {
    struct Create: AppView {
        @Environment(\.dismiss) var dismiss
        @State var title = ""
        var save: Throwable<Todo>?
        var body: some View {
            TextField("Title", text: $title)
                .onSubmit {
                    try? save?(.init(title: title))
                    dismiss()
                }
        }
    }
}

typealias Throwable<T> = (T) throws -> Void
typealias Completion<T> = (T) -> Void
typealias AppView = KeyPathMutable & View
