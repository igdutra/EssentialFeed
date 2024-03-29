//
//  UIRefreshControl+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 06/04/23.
//

import UIKit.UIRefreshControl

extension UIRefreshControl {
    /// Docs from scrollview: When the user initiates a refresh operation, the control generates a valueChanged event
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}

