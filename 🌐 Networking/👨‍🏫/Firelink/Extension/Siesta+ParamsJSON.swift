//
//  Siesta+JSONParams.swift
//  DevTemplate
//
//  Created by Raistlin on 2017/12/13.
//  Copyright © 2017年 jimlai. All rights reserved.
//

//import Siesta
//import SwiftyJSON

extension Resource {
    @discardableResult
    func post(_ pj: PJ) -> Request {
        return self.request(.post, json: pj.d)
    }
    @discardableResult
    func post(_ json: JSON) -> Request {
        return self.request(.post, json: json.toJSONConvertible())
    }
}

extension JSON {
    func toJSONConvertible() -> JSONConvertible {
        guard let data = try? self.rawData(), let jcon = try? JSONSerialization.jsonObject(with: data, options: []) else {
            return [String: Any]()
        }
        if let u = jcon as? Array<Any> {
            return u
        }
        else if let u = jcon as? [String: Any] {
            return u
        }
        else {
            return [String: Any]()
        }
    }
}
