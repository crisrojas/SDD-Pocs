//
//  Params.swift
//  DevTemplate
//
//  Created by Raistlin on 2017/12/13.
//  Copyright © 2017年 jimlai. All rights reserved.
//

import Siesta
import SwiftyJSON

typealias P = Params
enum Params: String, Codable {
    case none, full_name, url, items, test
}

extension JSON {
    subscript (paramKey: Params) -> JSON {
        return self[paramKey.rawValue]
    }
    
    static func << (_ json: inout JSON, _ dict: [Params: Any]) {
        json = JSON(dict.toStringKey())
    }

    init(_ pj: PJ) {
        self.init(pj.d)
    }
}

struct PJ: ExpressibleByDictionaryLiteral, CustomStringConvertible {
    var d = [String: Any]()
    var description: String {
        return d.description
    }
    init(dictionaryLiteral elements: (Params, Any)...) {
        var pj = [Params: Any]()
        for (k, v) in elements {
            pj[k] = v
        }
        d = pj.toStringKey()
    }
}

extension Dictionary where Key == Params {
    func toStringKey() -> [String: Any] {
        var d = [String: Any]()
        for k in self.keys {
            if let u = self[k] as? [Params: Any] {
                d[k.rawValue] = u.toStringKey()
                continue
            }
            d[k.rawValue] = self[k]
        }
        return d
    }
}
