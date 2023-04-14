//
//  UIControl+DSL.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 06/04/23.
//

import UIKit.UIControl

 extension UIControl {
     func simulate(event: UIControl.Event) {
         allTargets.forEach { target in
             actions(forTarget: target, forControlEvent: event)?.forEach {
                 (target as NSObject).perform(Selector($0))
             }
         }
     }
 }
