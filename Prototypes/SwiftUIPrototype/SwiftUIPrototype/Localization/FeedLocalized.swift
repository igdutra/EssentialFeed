//
//  FeedLocalized.swift
//  EssentialFeediOS
//
//  Created by Ivo on 17/04/23.
//

import Foundation

final class Feed: LocalizedStrings {
    private init() { }
    
    static let feed = localized("FEED_VIEW_TITLE")
    
    static func test(a: String, b: String) -> String {
        localized("test", a, b)
    }
}
