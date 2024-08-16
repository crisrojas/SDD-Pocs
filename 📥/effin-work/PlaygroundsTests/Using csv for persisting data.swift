//
//  Using csv for persisting data.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 23/11/23.
//

import Foundation

// https://www.hackingwithswift.com/articles/241/how-to-fetch-remote-data-the-easy-way-with-url-lines
fileprivate struct Todo: CSVFileFetchable {
    let id: UUID
    let description: String
    let isDone: Bool
}

func test() {
    let todos = Todo.fetch()
    todos.write()
}

// No error handling yet
protocol CSVFileFetchable: CSVCodable {}
extension CSVFileFetchable {
    static var path: String { .init(describing: Self.self) + ".csv" }
    
    static func fetch() -> [Self] {
        guard let file = readFile(path, "csv") else { return [] }
        let entities = file.components(separatedBy: "\n")
        return entities.compactMap(Self.init(csv:)) // @todo:
    }
}

protocol CSVFileWritable {}
extension Array where Element: CSVFileFetchable & CSVEncodable {
    func write() {
        guard let url = csvURL(Element.path) else { return }
        try? self
            .map { $0.encode() }
            .reduce("", {$0 + $1 + "\n" })
            .write(to: url, atomically: true, encoding: .utf8)
    }
}

extension Todo: CSVCodable {}
extension Todo {
    init?(csv: String) {
        let fields = csv.components(separatedBy: ",")
        guard fields.count == 3 else { return nil }
        guard let id = UUID(uuidString: fields[0]), let isDone = Bool(fields[2]) else { return nil }
        self.id = id
        description = fields[1]
        self.isDone = isDone
    }
}

extension String {
    func toBool() -> Bool {
        self == "TRUE" || self == "true"
    }
}

extension Int {
    func toBool() -> Bool { self == 1}
}


typealias CSVCodable = CSVDecodable & CSVEncodable
protocol CSVDecodable {
    init?(csv: String)
}

/// I wasn't brave/skilled enough to implement this, but this guy was:
/// https://github.com/dehesa/CodableCSV
extension CSVDecodable {
    func decode(data: String) -> Self? {nil}
}

protocol CSVEncodable {}
extension CSVEncodable {
    func encode() -> String {
        let mirror = Mirror(reflecting: self)
        let propertyValues = mirror.children.map { (label: String?, value: Any) in
            return "\(value)"
        }
        return propertyValues.joined(separator: ",")
    }
}


fileprivate func readFile(_ name: String, _ ext: String) -> String? {
    guard let path = Bundle.main.path(forResource: name, ofType: ext) else { return nil }
    return try? String(contentsOfFile: path, encoding: .utf8)
}

fileprivate func csvURL(_ name: String) -> URL? {
    Bundle.main.url(forResource: name, withExtension: "csv")
}
