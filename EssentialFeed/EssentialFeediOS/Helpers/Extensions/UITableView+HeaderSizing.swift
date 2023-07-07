//
//  UITableView+HeaderSizing.swift
//  EssentialFeediOS
//
//  Created by Ivo on 27/04/23.
//

import UIKit

extension UITableView {
    
    /* NOTE possible iOS update bug? Need to further investigate
     
     When moved the ErrorView from storyboard to code, this function would return always height = 33 for errorView, even when the title was nil and it should not be visible.
     
     Solution was to add a new closure to ErrorView, one to hide, the other to force the tableview header back to ErrorView.
     */
    func sizeTableHeaderToFit() {
        guard let header = tableHeaderView else { return }
        
        let size = header.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        let needsFrameUpdate = header.frame.height != size.height
        if needsFrameUpdate {
            header.frame.size.height = size.height
            tableHeaderView = header
        }
    }
}
