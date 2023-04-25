//
//  FeedErrorViewModel.swift
//  EssentialFeediOS
//
//  Created by Ivo on 21/04/23.
//

import Foundation

/* NOTE property and function
 
 Like the LocalizedStrings, no distinct difference between property and function
 
*/

/// Trying different name
struct FeedErrorViewData {
    let message: String?
    
    static var noError: FeedErrorViewData {
        return FeedErrorViewData(message: nil)
    }
    
    static func error(message: String) -> FeedErrorViewData {
        return FeedErrorViewData(message: message)
    }
}
