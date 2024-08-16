//
// Created by JimLai on 2020/2/29.
// Copyright (c) 2020 stargate. All rights reserved.
//

import SwiftUI

struct UID: Hashable {
    let U: Int
    let u: Int
    func isLater(than lastId: Int) -> Bool {
        guard U <= lastId+1, lastId+1 <= u else {return false}
        return true
    }
}

struct DepthItem: CustomStringConvertible {
    var description: String {
        "p: \(p), q: \(q)"
    }

    var price: String {
        NSDecimalNumber(decimal: p).stringValue
    }
    var quantity: String {
        NSDecimalNumber(decimal: q).stringValue
    }
    let p: Decimal
    let q: Decimal
    init(_ p: Decimal, _ q: Decimal) {
        self.p = p
        self.q = q
    }
}

struct OrderRow: Identifiable {
    let id: String
    let a: DepthItem
    let b: DepthItem
    let aqRatio: Double
    let bqRatio: Double

    init(_ a: DepthItem, _ b: DepthItem, _ aSum: Decimal, _ bSum: Decimal) {
        self.a = a
        self.b = b
        self.id = "\(a.p), \(b.p)"
        // magnify by 10 for visual effect, not accuracy
        aqRatio = Double(truncating: (a.q / aSum) as NSNumber) * 10
        bqRatio = Double(truncating: (b.q / bSum) as NSNumber) * 10
    }
}
