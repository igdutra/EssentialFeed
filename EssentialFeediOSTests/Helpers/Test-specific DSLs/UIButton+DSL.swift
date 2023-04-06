//
//  UIButton+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 06/04/23.
//

import UIKit.UIButton

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
