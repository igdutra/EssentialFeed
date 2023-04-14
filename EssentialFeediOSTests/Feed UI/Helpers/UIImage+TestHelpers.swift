//
//  UIImage+TestHelpers.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 06/04/23.
//

import UIKit.UIImage

extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        // Updated for iOS 15+
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        return UIGraphicsImageRenderer(size: rect.size, format: format).image { rendererContext in
            color.setFill()
            rendererContext.fill(rect)
        }
    }
}
