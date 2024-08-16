//
//  KeyPath mutation.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 19/11/23.
//

import SwiftUI
import XCTest

/// When updating a item persisted in a datastore, we usually end with many updated methods.
///
///
/// For example, let say you have an ingredients object:
///
fileprivate struct ShoppingListItem: Identifiable, Equatable  {
  let id: Int
  var name: String
  var isChecked: Bool
  var measureUnitId: Int?
  var quantity: Double
  let listId: Int
  var updatedAt: Date
}

/// You may end with an api like this.

fileprivate protocol LocalPersistenceAPI {
    func update(ingredient: ShoppingListItem)
    func updateItem(with id: Int, onList id: Int, title: String?)
    func updateItem(with id: Int, onList id: Int, isChecked: Bool?)
    func updateItem(with id: Int, onList id: Int, quantity: Double?)
    func updateItem(with id: Int, onList id: Int, measureUnitId: Int?)
    func updateItem(with id: Int, onList id: Int, ingredientId: Int?)
    func updateItem(with id: Int, onList id: Int, updatedAt: Date?)
}

/// Note you usually have an metod that takes the whole item.
/// For most persistency solutions and apps that method is all you need.
///
/// This playground goal is to find the best way of encoding item changes in order to use a single update entry point method.
///
/// The goal is to have an api that returns a modified item, which allows chaining changes.
/// Ex.)
///
/// let updatedItem = item
///   .update(.name("chicken"))
///   .udpate(.listId(24))
///
/// And then pass directly the encoded item to the entry point:
///
/// persistencySolution.update(updatedItem)
///
/// Would be this necessary in SwiftUI?
///
/// No, as you have direct bindings that do the job for you:
///

fileprivate enum PersistencySolution {
    static func update(_ item: ShoppingListItem) { }
}

fileprivate struct ItemEdit: View {
    @State var item: ShoppingListItem
    var persist: ((ShoppingListItem) -> Void)?
    var body: some View {
        VStack {
            /// Textfield input directly modifies the item.
            TextField("name", text: $item.name)
            Button("Save") {
                persist?(item)
            }
        }
    }
}

/// Would this be necessary in UIKit?
///
/// Nope, this seems coherent to me
fileprivate class ItemEditViewController {
    var item: ShoppingListItem!
    var textField: UITextField!
    var saveButton: UIButton!
    
    func viewDidLoad() {
        textField.delegate = self
    }
    
    func didTapSaveButton() {
        PersistencySolution.update(item)
    }
    
    func textFieldDidBeginEditing(textField: UITextField!) {
        item.name = textField.text
    }
}

/// This would be necesary if we use a global store that receives changes
/// like the one used with Khipu ?
///
/// Nope, I've just realized and update api isn't necessary:
///
fileprivate struct GlobalState {
    var items: [ShoppingListItem] = []
    
    enum Update {
        /// You usually would want create & delete commands too. For simplicity, lets keep one:
        case update(ShoppingListItem)
    }
    
    func update(_ update: Update) {
        /// Perform some changes depending on update
        /// Then return updated item
    }
}

@Observable fileprivate class KhipuStore {
    var appState = GlobalState()
    func receive(_ update: GlobalState.Update) {
        appState.update(update)
    }
}

/// Usage:
///
fileprivate struct ItemList: View {
    let store = KhipuStore()
    var body: some View {
        List(store.appState.items) { item in
            NavigationLink {
                ItemEdit(item: item, persist: persist)
            } label: {
                Text(item.name)
            }

        }
    }
    
    func persist(item: ShoppingListItem) {
        store.receive(.update(item))
    }
}




/// #private
/// Conformers implement an update type, ideally an enum which encodes self transformation.
/// They return a new instance of themselves after processing such transformations
///
protocol Updatable {
    /// Should be modeled with an enum type
    associatedtype UpdateType
    /// Returns an updated copy of self
    func update(_ update: UpdateType) -> Self
}

/// Allows conformers to update themselves through a map closure, thus allowing chaining:
/// someObject
///     .map { $0.someProperty    = "some value"          }
///     .map { $0.someOtherProp = "some other value" }
///
protocol Mappable {}
extension Mappable {
    func map(transform: (inout Self) -> Void) -> Self {
        var new = self
        transform(&new)
        return new
    }
}

typealias Copiable = KeyPathMutable & Mappable

protocol KeyPathMutable {}
extension KeyPathMutable {
    /// A mutating func as follows wouldn't be useful
    /// mutating func update<V>(_ kp: WritableKeyPath<Self, V>, with value: V)
    ///
    /// It would be redundan:
    ///
    /// person.update(\.name, 30)
    /// vs
    /// person.name = 30
    
    func updated<V>(_ kp: WritableKeyPath<Self, V>, with value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func makeCopy<V>(withUpdated kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    
    func with<V>(_ kp: WritableKeyPath<Self, V>, changedTo value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
    
    func injecting<V>(_ kp: WritableKeyPath<Self, V>, _ value: V) -> Self {
        var copy = self
        copy[keyPath: kp] = value
        return copy
    }
}


infix operator >>: AdditionPrecedence
func >><T, V>(lhs: T, rhs: (WritableKeyPath<T, V>, V)) -> T {
    var copy = lhs
    copy[keyPath: rhs.0] = rhs.1
    return copy
}


fileprivate protocol Updater {
    associatedtype T
    static func update<V>(_ type: T, _ kp: WritableKeyPath<T, V>, with value: V)
}

extension Updater {
    static func update<V>(_ type: T, _ kp: WritableKeyPath<T, V>, with value: V) {
        var copy = type
        copy[keyPath: kp] = value
        // do something with updated copy
    }
}


fileprivate enum UserCrud: Updater {
    typealias T = User
}

extension User: KeyPathMutable {}

func test_func_() {
    
    let capitalize = { (item: String) in item.capitalized }
    
    var item = Person(firstName: "cristian")
    
    do {
        let _ = item
            .updated(\.lastName, with: "Patiño")
            .map { $0.firstName = $0.firstName.capitalized + " " + "Felipe" }
        
        
        let _ = item.makeCopy(withUpdated: \.lastName, "Patiño")
    }
    
    let user = User(firstName: "Pepito", lastName: "González")
    
    let newUser = user
        .with(\.firstName, changedTo: "pepito"   )
        .with(\.lastName , changedTo: "rodriguez")
    
    
    UserCrud.update(user, \.lastName, with: "Gonzalo")
    
    let  _ = item
    >> (\.lastName, "Patiño Rojas")
    >> (\.lastName, "Cristian Felipe")
}


fileprivate struct Person: Mappable, KeyPathMutable {
    var firstName: String
    var lastName: String?
}

import SwiftUI
fileprivate struct TestView: View {
    @State var state = Person(firstName: "cristian")
    var body: some View {
        VStack {
            Text(state.firstName)
            Button("Change name") {
                
                /// - Copy making
                ///
                /// Mapped seems more useful than keyPath for this purpose as it allows
                /// multiple changes in the same closure, so you don't really have to chain changes
                let newState = state.map {
                    $0.firstName = "Cristian"
                    $0.lastName = "Felipe"
                }
            }
        }
    }
}

/// Copy making could be useful for dependency/injection chaging variables
/// which allows simplifiying deeply dev experience and improves speed.
///
///
/// For example, lets say we have a view, which has some initial configuration
///
fileprivate struct ProfileView: View {
    enum PrivacyLevel {
        case friend
        case friendsFriend
        case stranger
    }
    
    var privacyLevel = PrivacyLevel.friend
    var body: some View {
        VStack {/* View Implem  */}
    }
}


/// We could inject privacyLevel through init and give it a default value there
///
/// However, this becomes tedious the more you properties you have in your view.
///
extension ProfileView: KeyPathMutable {}


/// With a copy making approach you can inject values if you need to change them before making something
/// with the object:
///
fileprivate let profile = ProfileView()
    .injecting(\.privacyLevel, .stranger)

// MARK: - Tests
//
import XCTest
import SwiftUI

final class Protocols: XCTest {
    
    struct TestView: View, Mappable {
        @State var greeting = "hello"
        var body: some View {
            Text(greeting)
        }
    }
    
    func test_mappable() {
        let test = TestView().map { $0.greeting = "hello world" }
        XCTAssertEqual(test.greeting, "hello world")
    }
}

// MARK: - UIKit
//
fileprivate final class UITextField {
    var delegate: Any?
    var text: String = ""
}

fileprivate final class UIButton {var title = ""}
