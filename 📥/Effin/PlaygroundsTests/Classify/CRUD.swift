/*
CodeRunner

Este es un pequeño experimento en el que intento construir una api de persistencia con únicamente 4 puntos de entrada (métodos):

create()
read()
update()
delete()
*/

import Foundation

protocol DomainObject: Identifiable { }
struct Task: DomainObject { let id: UUID }
struct Area: DomainObject { let id: UUID }
struct Item: DomainObject { let id: UUID }
struct Tag : DomainObject { let id: UUID }

enum PersistenceError: Error {
    case entityCantBeNil
}

enum Domain {
    case task(Task)
    case area(Area)
    case item(Item)
    case tag(Tag)
}


protocol PersistenceClient {
    associatedtype DomainType
    func create(_ table: Domain) throws
    func update(_ table: Domain) throws
    func delete(_ table: Domain) throws
}

final class PersistenceClientImplementation: PersistenceClient {

    typealias DomainType = Domain
        // MARK: - C
    func create(_ table: Domain) throws {
        switch table {
            case let .task(task): try create(task)
            case let .area(area): try create(area)
            case let .item(item): try create(item)
            case let .tag (tag) : try create(tag)
        }
    }
    
    // MARK: - R
    func readTasks() throws -> [Task] {fatalError("todo")}
    func readAreas() throws -> [Area] {fatalError("todo")}
    func readItems() throws -> [Item] {fatalError("todo")}
    func readTags()  throws -> [Tag]  {fatalError("todo")}
    
    func readTask(id: UUID) throws -> Task {fatalError("todo")}
    func readArea(id: UUID) throws -> Area {fatalError("todo")}
    func readItem(id: UUID) throws -> Item {fatalError("todo")}
    func readTag (id: UUID) throws -> Tag  {fatalError("todo")}
    
    // MARK: - U
    func update(_ table: Domain) throws {
        switch table {
            case let .task(task): try update(task)
            case let .area(area): try update(area)
            case let .item(item): try update(item)
            case let .tag (tag) : try update(tag)
        }
    }
    
    // MARK: - D
    func delete(_ table: Domain) throws {
        switch table {
            case let .task(task): try delete(task)
            case let .area(area): try delete(area)
            case let .item(item): try delete(item)
            case let .tag (tag) : try delete(tag)
        }
    }
    
    private func create(_ item: Item) throws {}
    private func create(_ task: Task) throws {}
    private func create(_ area: Area) throws {}
    private func create(_ tag: Tag) throws {}
    
    private func update(_ item: Item) throws {}
    private func update(_ task: Task) throws {}
    private func update(_ area: Area) throws {}
    private func update(_ tag: Tag) throws {}
    
    private func delete(_ item: Item) throws {}
    private func delete(_ task: Task) throws {}
    private func delete(_ area: Area) throws {}
    private func delete(_ tag: Tag) throws {}
}

let client = PersistenceClientImplementation()

let task = Task(id: UUID())
let item = Item(id: UUID())
let area = Area(id: UUID())
let tag  = Tag(id: UUID())

fileprivate func main() throws {
    try client.create(.item(item))
    try client.create(.task(task))
    try client.create(.area(area))
    try client.create(.tag(tag))
    
    try client.update(.task(task))
    try client.update(.area(area))
    try client.update(.item(item))
    try client.update(.tag(tag))
    
    try client.delete(.task(task))
    try client.delete(.area(area))
    try client.delete(.item(item))
    try client.delete(.tag(tag))
}
