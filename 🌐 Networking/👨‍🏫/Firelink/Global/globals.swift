//
//  globals.swift
//  DevTemplate
//
//  Created by Raistlin on 2017/12/13.
//  Copyright © 2017年 jimlai. All rights reserved.
//
import UIKit

let api = API()

// debug print
func dp(_ items: Any ...) {
#if DEBUG
    print(items)
#endif
}


extension UIViewController {
    static var name: String {
        return String(describing: self)
    }
}

infix operator !?

public func !? <T>(wrapped: T?, nilDefault: @autoclosure () -> (value: T, text: String)) -> T {
    assert(wrapped != nil, nilDefault().text)
    return wrapped ?? nilDefault().value
}

func sb<T>() -> T where T: UIViewController {
    return UIStoryboard(name: T.name, bundle: Bundle.main).instantiateInitialViewController() as? T !? (T(), "\(T.name) not instantiated")
}


