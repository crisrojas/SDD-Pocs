//
//  HowToPost.swift
//  Bonfire
//
//  Created by Cristian Felipe Patiño Rojas on 21/12/2023.
//

import Combine
import Foundation

/// @question: What if we need some other actions for a resource ? POST/PUT/PATCH
///  Use the load(using:) method:
final class TodoResource: Resource {
    var cancellable: AnyCancellable?
    static var mods = [String : (Request<MJ>) -> Request<MJ>]()
    var url: String = "test"
    var error: Error?
    var response: HTTPURLResponse?
    var contentType = "application/json"

    @Published var data = MJ.raw("data")
}

let todos = TodoResource()
struct TodoPOST: HttpBody, Encodable {
    let title: String
    let notes: String
    var isChecked = false
    var body: Data? { try? JSONEncoder().encode(self) }
}

let postRequest = todos.request(.post, TodoPOST(title: "Buy apples", notes: "freaking love 🍎s"))
let POST = todos.load(using: postRequest)
