//
//  SCButton.swift
//  DevTemplate
//
//  Created by jimlai on 2018/5/8.
//  Copyright © 2018年 jimlai. All rights reserved.
//

import UIKit

extension UIViewController {
    func fat(_ sel: Selector) -> (UIButton) -> () {
        return { (button: UIButton) in
            button.addTarget(self, action: sel, for: .touchUpInside)
        }
    }
}


infix operator <<
func <<(_ lhs: UIButton, _ rhs: (UIButton) -> ()) {
    rhs(lhs)
}
