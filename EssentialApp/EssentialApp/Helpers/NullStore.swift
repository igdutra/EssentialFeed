//
//  NullStore.swift
//  EssentialApp
//
//  Created by Ivo on 04/09/23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed() throws { }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date) throws { }
    
    func retrieve() throws -> CachedFeed? { .none }
    
    // MARK: - FeedImageDataStore
    
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
    
    func insert(_ data: Data, for url: URL) throws { }
}
