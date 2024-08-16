//
//  Observable resource with callbacks.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 20/11/23.
//

import Foundation
/// tests
/// Protocol Orient approach for creating a resource based architecture approach
///
/// Such architecture is based in the follow separation of concerns:
///
/// Instead of having an object that is charged of fetching a resource
/// (aka Repository) splitted in many sub objects (aka UseCases)
/// a resource should be able to retireve itself and perform the pertinent CRUD 
/// operations (see FilePersistable protocol for an example of this approach)
///
/// This is a flexible approach used in networking (resource based networking)
///
/// Some libraries, like Siesta, push the approach one level further: 
///
/// Resources are not only responsible for knowing how to perform the basic CRUD operations,
/// but they also need to hold their own state and be able to notify on state changes to observers.
///
/// For such behaviour we would need observers to have a shared instance:
///
/// final class Observer1 { var observable = Api.observedResource }
/// final class Observer2 { var observable = Api.observedResource }
///
/// We can push further the idea to a different domain: Persistency (heck we could even make a network resource observable & persistable!!!)
///
/// The idea is to have a common protocol that would define the contract of what an observableResource would need, and then have persistency protocols
/// for each persistency solution. The latest would "inherit" from it and implement defaults through protocol extension.
///
/// ex.:)
/// SQLiteObservableResource
/// FileCodableObservableResource
/// CoreDataObservableResource
/// etc...
///
/// This is my attempt to implement a FileCodableObservableResource.
/// I could have used combine, but wanted the thing to work with UIKit, so rely on callbacks and Jim Lai awesomely simple (yet powrful) Rx<T> struct
///
///

// MARK: - First Attempt: Generic Class

///
///
/// We want to have an observable resource that shares its state through the app
final class ObsResource<T: Identifiable> {
    typealias Collection = [T]
    var resource = Collection() {didSet{notify()}}
    var observers = [(Collection)->Void]()
    func notify() {observers.forEach({$0(resource)})}
    func get() -> Collection {[]}
    func get(id: T.ID) -> T? {nil}
    func upsert(_ item: T) {
        resource = resource.filter {$0.id != item.id} + [item]
    }
    func delete(id: T.ID){}
    func observe(_ observer: @escaping (Collection)->Void) {observers.append(observer)}
    
    func bind<U: AnyObject, V>(_ keyPath: ReferenceWritableKeyPath<U, V>, of object: U, with mapping: @escaping (Collection) -> V) {
        let observer = { [weak object] (newValue: Collection) in
            if let object {
                object[keyPath: keyPath] = mapping(newValue)
            }
        }
        observers.append(observer)
    }
}


/// Some sintatic sugar for appending observers
infix operator ~<: AdditionPrecedence
func ~<<U>(_ lhs: inout ObsResource<U>, _ obs: @escaping ([U]) -> ()) {
    lhs.observe(obs)
}


fileprivate final class TableView {
    var dataSource = [String]() { didSet {reload()}}
    func reload() {}
}

fileprivate final class ViewController {
    
    var observable = Db.users
    lazy var tableView = TableView()
    
    func viewDidLoad() {
        observable ~< process(users:)
        observable.bind(\.dataSource, of: tableView, with: {$0.map{$0.firstName}})
    }
    
    func process(users: [User]) {}
}

fileprivate final class ViewController2 {
    var observable = Db.users
    var unwrappedUser: User?
    func viewDidLoad() {
        observable ~< process(users:)
    }
    
    func process(users: [User]) {
        unwrappedUser = users.first
    }
}

enum Db {
    static var users = ObsResource<User>()
}

import XCTest
fileprivate final class Tests: XCTestCase {
    
    var vc1: ViewController!
    var vc2: ViewController2!
    
    override func setUp() {
        vc1 = .init()
        vc2 = .init()
    }
   
    func test() throws {
        vc1.viewDidLoad()
        vc2.viewDidLoad()
        vc1.observable.upsert(.init(firstName: "Cristian", lastName: "Felipe"))
        XCTAssertEqual(vc1.tableView.dataSource.first, "Cristian")
        let user = try XCTUnwrap(vc2.unwrappedUser)
        XCTAssertEqual(user.firstName, "Cristian")
    }
}

// MARK: - Observable resource through protocol
fileprivate struct Rx<T> {
    typealias Observer = (T)->Void
    var value: T {didSet{notify()}}
    var observers: [Observer]
    func notify() {observers.forEach {$0(value)}}
    mutating func observe(_ obs: @escaping Observer) {observers.append(obs)}
    
    init(value: T, observers: [Observer]) {
        self.value = value
        self.observers = observers
    }
}

/// Wee need our observable to hold an array, so T must conform to collection.
extension Rx where T: Collection, T.Element: Identifiable {
    func get(id: T.Element.ID) -> T.Element? {
        value.first { $0.id == id }
    }
    
    /// @todo: This could crash if T isn't an Array/Set
    mutating func upsert(_ item: T.Element) {
        value = value.filter {$0.id == item.id} + [item] as! T
    }
    
    /// @todo: This could crash if T isn't an Array/Set
    mutating func delete(id: T.Element.ID) {
        value = value.filter {$0.id == id} as! T
    }
}

/// Underescoded till I successfully refactor
fileprivate protocol ObservableResource: AnyObject {
    associatedtype T: Collection where T.Element: Identifiable
    typealias Observer = (T)->Void
    var resource : Rx<T> {get set}
    func get() -> T
    func get(id: T.Element.ID) -> T.Element?
    func upsert(_ item: T.Element)
    func delete(id: T.Element.ID)
    func onChange(_ obs: @escaping (T)->Void)
    
    /// @todo: implement
    /// func bind<U: AnyObject, V>(_ keyPath: ReferenceWritableKeyPath<U, V>, of object: U, with mapping: @escaping (ArrayOfT) -> V)
}

extension ObservableResource {
    func onChange(_ obs: @escaping (T)->Void) {
        resource.observe(obs)
    }
}


/// Should find a shorter name. Thought this is meant to remain fileprivate since only concrete type is needed.
fileprivate protocol FileCodableObservableResource: ObservableResource where T == C {
    associatedtype C: Codable where C.Element: Codable
    
    /// A file observable would need an id to construct the path where it will be persisted
    /// This allows to unit test without overriding  values that we may have on simulator.
    var id: String {get set}
}


/// Commo coders. Declared at filescop so we don't have instances per type that conforms the protocol.
fileprivate var jsonEncoder = JSONEncoder()
fileprivate var jsonDecoder = JSONDecoder()

extension FileCodableObservableResource {
    var path: String { String(describing: C.Element.self) + "-" + id + ".json" }

    func get() -> C {
        let data = try! Data(contentsOf: try! fileURL())
        return try! jsonDecoder.decode(C.self, from: data)
    }
    
    func write(_ resources: C) throws {
        #if DEBUG
        jsonEncoder.outputFormatting = .prettyPrinted
        #endif
        
        let data = try jsonEncoder.encode(resources)
        try data.write(to: fileURL())
    }
    
    func get(id: C.Element.ID) -> C.Element? {
        resource.get(id: id)
    }
    
    func upsert(_ item: T.Element) {
        resource.upsert(item)
    }
    
    func delete(id: T.Element.ID) {
        resource.delete(id: id)
    }
    
    func destroy() throws {
        try FileManager.default.removeItem(atPath: fileURL().path)
    }

    func fileURL() throws -> URL {
        try FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent(path)
    }
}


/// Need a concrete class because I couldn't find a way of automatically setting a
/// subscription that writes to disk through protocol extension.
fileprivate
final class FileObservableResource<T: Codable & Identifiable>: FileCodableObservableResource {
    typealias C = [T]
    var resource: Rx<C> = .init(value: [], observers: [])
    var id: String
    
    init(id: String = String(describing: T.self)) {
        self.id = id
        resource.observe({
            [weak self] resources in
            try! self?.write(resources)
        })
    }
}

fileprivate final class Tests_2: XCTestCase {
    
    func test() {
        
        Describe("Observable persists to disk") {
            Given("Initially empty observable") {
                let observable = self.observable()
                
                When("Adding a new user to it") {
                    observable.upsert(.init(firstName: "cristian", lastName: "rojas"))
                    
                    It("Is persisted to disk") {
                        let users: [User]? = observable.get()
                        XCTAssertEqual(users?.first?.firstName, "cristian")
                    }
                }
            }
        }
        
        
        Describe("Observable notifies different observers") {
            Given("Two different VCs with a common observable instance") {
                let obs1 = Observer()
                let obs2 = Observer()
                
                let shared = self.observable(id: "shared instance")
                obs1.observable = shared
                obs2.observable = shared
                
                And("VCs started observing") {
                    obs1.startObserving()
                    obs2.startObserving()
                    
                    When("Adding a new item to observable through one of the VCs") {
                        
                        obs1.observable.upsert(.init(firstName: "cristian", lastName: "patiño rojas"))
                        
                        Then("Both VC are notified") {
                            XCTAssertEqual(obs1.name, "cristian")
                            XCTAssertEqual(obs1.name, obs2.name)
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func observable(id: String = "tests") -> FileObservableResource<User> {
        let sut = FileObservableResource<User>(id: id)
        addTeardownBlock { try sut.destroy() }
        return sut
    }
}

extension Tests_2 {
    final class Observer {
        var observable = FileObservableResource<User>()
        var name: String?

        func startObserving() {
            observable.onChange(updateUI(_:))
        }
        
        func updateUI(_ users: [User]) {name = users.first?.firstName}
    }
}

