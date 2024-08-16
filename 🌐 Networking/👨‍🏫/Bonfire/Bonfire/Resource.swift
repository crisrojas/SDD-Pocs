//
//  ResourceImplementatino.swift
//  Bonfire
//
//  Created by Cristian Felipe Patiño Rojas on 21/12/2023.
//

import Foundation
import Combine

typealias AppRequest<T: Decodable> = Request<Wrapper<T>>

public final class EmployeesCodable: Resource {
    var cancellable: AnyCancellable?
    static var mods = [String : (AppRequest<Employee>) -> AppRequest<Employee>]()
    var url: String = "employees"
    var error: Error?
    var response: HTTPURLResponse?
    var contentType = "application/json"

    @Published var data = Wrapper<Employee>()
    var employes: [Employee] {data.data ?? []}
}

public final class EmployeesMJ: Resource {
    var cancellable: AnyCancellable?
    static var mods = [String : (Request<MJ>) -> Request<MJ>]()
    var url: String = "employees"
    var error: Error?
    var response: HTTPURLResponse?
    var contentType = "application/json"

    @Published var data = MJ.raw("data")
    

    
    /// Testing this so we can use it on swiftui
    var list: [Int:MJ] {
        Dictionary(uniqueKeysWithValues: data[P.data].arrayValue.map { ($0[EK.id].intValue, $0) })
    }
}
extension Dictionary {
    func tuples() -> [(id: Key, value: Value)] {
        map { (id: $0.key, value: $0.value)}
    }
}

class JSON: Resource {
    
    var cancellable: AnyCancellable?
    static var mods = [String : (Request<MJ>) -> Request<MJ>]()
    var url: String
    var error: Error?
    var response: HTTPURLResponse?
    var contentType = "application/json"
    
    @Published var data = MJ.raw("data")

    init(_ relURL: String) {
        url = relURL
    }
}
