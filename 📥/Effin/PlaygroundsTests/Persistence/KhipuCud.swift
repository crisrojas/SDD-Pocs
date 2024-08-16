//
//  KhipuCud.swift
//  Effin
//
//  Created by Cristian Felipe Patiño Rojas on 03/12/2023.
//

import Foundation

fileprivate struct ToDo: Identifiable, Equatable {
    let id: UUID
    var name: String
    var isChecked: Bool
    var projectId: UUID?
    
    init(id: UUID = UUID(), name: String, isChecked: Bool = false, projectId: UUID? = nil) {
        self.id = id
        self.name = name
        self.isChecked = isChecked
        self.projectId = projectId
    }
}

fileprivate struct Project: Identifiable {
    let id: UUID
    var name: String
}

enum UD_Command<T> {
    case upsert(T)
    case delete(T)
}

fileprivate struct AppState {
    fileprivate(set) var todos    = [ToDo]()
    fileprivate(set) var projects = [Project]()
}

extension AppState {
    enum Update {
        case todos(UD_Command<ToDo>)
        case projects(UD_Command<Project>)
    }
    
    func update(_ command: Update) -> Self {
        var updatedCopy = self
        switch command {
        case .todos(let cmd): updatedCopy.todos.handle(cmd)
        case .projects(let cmd): updatedCopy.projects.handle(cmd)
        }
        return updatedCopy
    }
    
    mutating func update<T: Identifiable>(_ keyPath: WritableKeyPath<AppState, [T]>, with cmd: UD_Command<T>) {
        self[keyPath: keyPath].handle(cmd)
    }
}

extension Array where Element: Identifiable {
    typealias Command = UD_Command<Element>
    mutating func handle(_ command: UD_Command<Element>) {
        switch command {
        case .upsert(let item):
            self = filter { $0.id != item.id } + [item]
        case .delete(let item):
            self = filter { $0.id != item.id }
        }
    }
}

fileprivate typealias Access  = () -> AppState
fileprivate typealias Observe = (@escaping()->()) -> Void
fileprivate typealias Update  = (AppState.Update) -> Void
fileprivate typealias Map     = ((inout AppState) -> Void) -> Void

fileprivate typealias StateStore = (
    access : Access,
    observe: Observe,
    update : Update,
    map    : Map
)

fileprivate func createRamStore() -> StateStore {
    var s = AppState() {didSet {c.forEach {$0()}}}
    var c = [()->()]()
    
    return (
        access : { s            },
        observe: { c.append($0) },
        update : { s = s.update($0) },
        map: { transform in
            transform(&s)
        }
    )
}

import XCTest

fileprivate final class StoreTests: XCTestCase {
    
    func test_update() {
        let sut = createRamStore()
        let todo = ToDo(name: "Do laundry")
        sut.update(.todos(.upsert(todo)))
        let first = sut.access().todos.first
        XCTAssertEqual(first, todo)
    }
    
    func test_update_with_keypath() {
        let sut = createRamStore()
        let todo = ToDo(name: "Do laundry")
        sut.map { $0.update(\.todos, with: .upsert(todo)) }
        let first = sut.access().todos.first
        XCTAssertEqual(first, todo)
    }
}
