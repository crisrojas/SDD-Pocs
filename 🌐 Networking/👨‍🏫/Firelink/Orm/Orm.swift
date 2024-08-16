//
//  Orm.swift
//  Firelink
//
//  Created by jimlai on 2018/10/8.
//  Copyright © 2018年 jimlai. All rights reserved.
//

import Foundation
import SQLite

protocol Orm: CustomStringConvertible {
    var id: RC<Int> {get set}
    static var name: String {get}
    static var table: SQLite.Table {get set}
    static func create() -> SQLite.Table
    static func make() -> Self
    func insert()
    static func all() -> [Self]
    static func update(_ filter: Expression<Bool?>?, _ setters: [Setter?]) -> Bool
    static var db: Connection? {get set}
    static var first: Row? {get}
    static func load(_ row: Row?) -> Self?

}

extension Orm {
    static var name: String {
        return "\(Self.self)"
    }
    static var first: Row? {
        guard let db = Self.db else {
            return nil
        }
        do {
            return try db.pluck(Self.table)
        }
        catch {
            return nil
        }
    }
    static func create() -> SQLite.Table {
        let table = SQLite.Table(Self.name)
        let mirror = Mirror(reflecting: Self.make())
        let _ = try? gdbc?.run(table.create {t in
            for prop in mirror.children {
                guard let s = prop.label, let ccp = prop.value as? CCP else {
                    continue
                }
                ccp.build(s, t)
            }
        })
        return table
    }
    func insert() {
        guard let db = Self.db else {
            return
        }
        let table = Self.table
        let mirror = Mirror(reflecting: self)
        let setters: [Setter] = mirror.children.compactMap { prop in
            guard let s = prop.label, var ccp = prop.value as? CCP else {
                return nil
            }
            ccp.name = s
            return ccp.setter(s)
        }
        let _ = try? db.run(table.insert(setters))
    }

    static func update(_ filter: Expression<Bool?>? = nil, _ setters: [Setter?]) -> Bool {
        guard let db = Self.db else {
            return false
        }
        let table = Self.table
        let compact = setters.compactMap{$0}
        if let filter = filter {
            let rows = table.filter(filter)
            _ = try? db.run(rows.update(compact))
        }
        else {
            _ = try? db.run(table.update(compact))
        }
        return true
    }

    static func all() -> [Self] {
        guard let db = Self.db, let rows = try? db.prepare(Self.table) else {
            return []
        }
        var res = [Self]()
        for row in rows {
            guard let rc = load(row) else {
                continue
            }
            res.append(rc)
        }
        return res
    }
    static func load(_ row: Row?) -> Self? {
        guard let row = row else {
            return nil
        }
        let rc = Self.make()
        let mirror = Mirror(reflecting: rc)
        for prop in mirror.children {
            guard let s = prop.label, var ccp = prop.value as? CCP else {
                continue
            }
            ccp.name = s
            ccp.eval(s, row)
        }
        return rc
    }
    var description: String {
        let mirror = Mirror(reflecting: self)
        var d = [String: Any]()
        for prop in mirror.children {
            guard let s = prop.label, let ccp = prop.value as? CCP else {
                continue
            }
            d[s] = ccp.description
        }
        return "\(d)"
    }
}
func ==<U, V>(_ lhs: KeyPath<U, RC<V>>, _ rhs: V) -> Expression<Bool?> where U: Orm, V: Value, V.Datatype: Equatable {
    guard let exp = U.load(U.first)?[keyPath: lhs].exp else {
        return Expression<Bool?>(value: nil)
    }
    return exp == rhs
}

func !=<U, V>(_ lhs: KeyPath<U, RC<V>>, _ rhs: V) -> Expression<Bool?> where U: Orm, V: Value, V.Datatype: Equatable {
    guard let exp = U.load(U.first)?[keyPath: lhs].exp else {
        return Expression<Bool?>(value: nil)
    }
    return exp != rhs
}

func <-<U, V>(_ lhs: KeyPath<U, RC<V>>, _ rhs: V) -> Setter? where U: Orm, V: Value {
    guard let exp = U.load(U.first)?[keyPath: lhs].exp else {
        return nil
    }
    return exp <- rhs
}

let path = NSSearchPathForDirectoriesInDomains(
    .documentDirectory, .userDomainMask, true
    ).first!

let gdbc: Connection? = {
    let db = try? Connection("\(path)/db2.sqlite3")
    db?.busyTimeout = 5

    db?.busyHandler({ tries in
        if tries >= 3 {
            return false
        }
        return true
    })
    return db
}()


protocol CCP: CustomStringConvertible {
    func build(_ s: String, _ t: TableBuilder)
    func setter(_ name: String) -> Setter
    func eval(_ name: String, _ row: Row)
    var name: String? {get set}
}

enum CC {
    case def, pri, notSpecified
    func apply<T>(_ s: String, _ t: TableBuilder, _ def: T) where T: Value {
        switch self {
        case .pri:
            t.column(Expression<Int64>(s), primaryKey: PrimaryKey.autoincrement)
        case .def:
            t.column(Expression<T>(s), defaultValue: def)
        default:
            t.column(Expression<T?>(s))
        }
    }
}

final class RC<T>: CCP where T: Value {
    var name: String?
    var val: T?
    let def: T
    let cc: CC
    var unwrapped: T {
        return val ?? def
    }
    init(_ def: T, _ cc: CC = .notSpecified) {
        self.def = def
        self.cc = cc
    }
    func build(_ s: String, _ t: TableBuilder) {
        cc.apply(s, t, def)
    }
    func setter(_ name: String) -> Setter {
        return Expression<T?>(name) <- val
    }
    func eval(_ name: String, _ row: Row) {
        val = row[Expression<T?>(name)]
    }
    var description: String {
        return val == nil ? "nil" : "\(val!)"
    }
    var exp: Expression<T?>? {
        guard let name = name else {
            return nil
        }
        return Expression<T?>(name)
    }
}


struct User: Orm {
    static var db: Connection? = gdbc
    static var table = User.create()
    static func make() -> User {
        return User()
    }

    var id = RC(0, .pri)
    var tesla = RC("elon")

}
