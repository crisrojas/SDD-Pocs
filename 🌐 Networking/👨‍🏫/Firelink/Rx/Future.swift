//
//  Future.swift
//  Firelink
//
//  Created by jimlai on 2018/8/31.
//  Copyright © 2018年 jimlai. All rights reserved.
//

import UIKit

struct Future<U> {
    var u: U? {
        didSet {
            promise?(u)
        }
    }
    var promise: ((U?) -> ())?
    func then<V>(_ action: @escaping (U?, Future<V>) -> ()) -> Future<V> {
        let p = Promise(action, self)
        return p.fv
    }
}

struct Promise<U, V> {
    var fu: Future<U>
    let fv: Future<V>
    init(_ action: @escaping (U?, Future<V>) -> (), _ fu: Future<U> = Future<U>(), _ fv: Future<V> = Future<V>()) {
        self.fu = fu
        self.fv = fv
        let p: (U?) -> () = { u in
            action(u, fv)
        }
        self.fu.promise = p
    }
}
