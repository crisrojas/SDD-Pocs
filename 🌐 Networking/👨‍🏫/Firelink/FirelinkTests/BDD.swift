//
//  BDD.swift
//  DevTemplateTests
//
//  Created by jimlai on 2018/4/20.
//  Copyright © 2018年 jimlai. All rights reserved.
//

import Foundation

func describe(_ description: String, _ cls: @escaping () -> ()) {
    recursive(cls)
}
func when(_ description: String, _ cls: @escaping () -> ()) {
    recursive(cls)
}

func when<T>(_ description: String, _ td: T, _ cls: @escaping () -> ()) {

}
func it(_ description: String, _ cls: @escaping () -> ()) {
    Node.cur?.its.append(cls)
}
func beforeEach(_ description: String, _ cls: @escaping () -> ()) {
    Node.cur?.before.append(cls)
}

func recursive(_ cls: @escaping () -> ()) {
    let n = Node(cls)
    Node.cur?.nodes.append(n)
    n.parent = Node.cur
    Node.cur = n
    n.before += n.parent?.before ?? []
    n.cls()
    for i in n.its {
        n.before.forEach {$0()}
        i()
    }
    Node.cur = n.parent
}

class Node {
    static var head = Node({})
    static var cur: Node? = head
    var parent: Node?
    var nodes = [Node]()
    let cls: () -> ()
    var before = [() -> ()]()
    var its = [() -> ()]()
    init(_ cls: @escaping () -> ()) {
        self.cls = cls
    }
}
