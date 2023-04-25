//
//  UIButton+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 06/04/23.
//

import UIKit.UIButton

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
