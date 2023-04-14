//
//  UITableView+Dequeueing.swift   .swift
//  EssentialFeediOS
//
//  Created by Ivo on 14/04/23.
//

import UIKit.UITableView

 extension UITableView {
     // Here it is safe to force-unwrap + backed by tests
     func dequeueReusableCell<T: UITableViewCell>() -> T {
         let identifier = String(describing: T.self)
         return dequeueReusableCell(withIdentifier: identifier) as! T
     }
 }
