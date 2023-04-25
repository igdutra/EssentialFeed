//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Ivo on 21/04/23.
//

import UIKit.UIRefreshControl

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
