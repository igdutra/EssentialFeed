//
//  UIView+TestHelpers.swift
//  EssentialAppTests
//
//  Created by Ivo on 27/04/23.
//

import UIKit

extension UIView {
    func enforceLayoutCycle() {
        layoutIfNeeded()
        RunLoop.current.run(until: Date())
    }
}
