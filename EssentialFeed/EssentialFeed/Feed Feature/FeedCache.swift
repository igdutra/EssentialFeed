//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Ivo on 26/04/23.
//

import Foundation

public protocol FeedCache {
    func save(_ feed: [FeedImage]) throws
}

// MARK: - Async FeedCache for Decorator
public protocol FeedCacheAsync {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
