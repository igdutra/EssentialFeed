//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Ivo on 26/04/23.
//

import Foundation

public protocol FeedImageDataCache {
    // This result type is no longer needed
    // Leaving for FeedImageDataLoaderCacheDecorator
    typealias Result = Swift.Result<Void, Error>
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
 
    func save(_ data: Data, for url: URL) throws
}

// Not break clients
public extension FeedImageDataCache {
    func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void) { }
}
