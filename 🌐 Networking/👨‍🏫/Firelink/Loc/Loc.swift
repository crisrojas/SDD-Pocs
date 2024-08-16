//
//  Loc.swift
//  DevTemplate
//
//  Created by jimlai on 2018/4/24.
//  Copyright © 2018年 jimlai. All rights reserved.
//

import UIKit

protocol Loc {
    func loc()
}

protocol Localizable: class {
    var ls: String {get set}
}

extension UITextField: Localizable {
    var ls: String {
        get {
            return self.text ?? ""
        }
        set {
            self.text = newValue
        }
    }
}

extension UILabel: Localizable {
    var ls: String {
        get {
            return self.text ?? ""
        }
        set {
            self.text = newValue
        }
    }
}

infix operator <<
func <<(_ lhs: Localizable, _ rhs: LocalizableString) {
    lhs.ls = rhs.ls()
}

infix operator >>: AdditionPrecedence
@discardableResult
func >>(_ lhs: String, _ rhs: Localizable) -> String {
    rhs.ls = lhs
    return lhs
}

prefix operator ~
prefix func ~(_ key: Int) -> String {
    return NSLocalizedString(String(key), comment: "")
}

typealias L = LocalizableString
enum LocalizableString: Int {
    case ok = 1, cancel = 2, ph = -1
    func ls() -> String {
        switch self {
        case .ph:
            return NSLocalizedString("placeholder", comment: "")
        default:
            return NSLocalizedString(String(self.rawValue), comment: "")
        }

    }
}

extension ViewController {
    func loc() {
        nameMsg << .ok
        ~1 >> pwdMsg >> nameMsg
    }
}
