//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Ivo on 06/02/23.
//

import Foundation

// Note: Public for EssentialAppLegacy
public final class FeedCachePolicy {
    private init() { }
    
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCacheAgeInDays: Int {
        return 7
    }
    
    public static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
