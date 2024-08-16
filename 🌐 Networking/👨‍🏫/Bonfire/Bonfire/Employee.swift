//
//  Employee.swift
//  Bonfire
//
//  Created by Cristian Felipe Patiño Rojas on 21/12/2023.
//

import Foundation


struct Wrapper<T: Decodable>: Decodable,  NetData {
    var data: [T]?
}


typealias P = Params
enum Params: String, JSONKey {
    var jkey: String { self.rawValue }
    case data
}

typealias EK = EmployeeKeys
enum EmployeeKeys: String, JSONKey {
    var jkey: String { self.rawValue }
    case id
    case name   = "employee_name"
    case age    = "employee_age"
    case salary = "employee_salary"
}


public struct Employee: Decodable, Identifiable {
    public let id: Int
    let name: String
    let age: Int
    let salary: Int
}

extension Employee {
    enum CodingKeys: String, CodingKey {
        case id
        case name   = "employee_name"
        case age    = "employee_age"
        case salary = "employee_salary"
    }
}
