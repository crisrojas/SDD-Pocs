//
//  AppIdeas.swift
//  PlaygroundsTests
//
//  Created by Cristian Patiño Rojas on 22/11/23.
//

import Foundation

/// Routinery + Toggle
///
struct Routine {
    let id: UUID
    let items: Set<Item>
    let name: String
    let index: String
}

extension Routine {
    struct Item: Hashable {
        let id: UUID
        let name: String
        let toggleProjectId: UUID?
        let index: Int
        let duration: Double
    }
}

struct ToggleProject { let id: UUID }

/// Xcode blog
///
///
struct File {
    enum Kind {
        case folder
        case file(ext: String)
    }
    var childs: [File]
    var path: String
}
