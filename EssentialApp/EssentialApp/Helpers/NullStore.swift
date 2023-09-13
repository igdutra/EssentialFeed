//
//  NullStore.swift
//  EssentialApp
//
//  Created by Ivo on 04/09/23.
//

import Foundation
import EssentialFeed

class NullStore: FeedStore & FeedImageDataStore {
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        completion(.success(()))
    }
    
    func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.success(.none))
    }
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void) {
        completion(.success(()))
    }
    
    // MARK: - FeedImageDataStore
    
    func retrieve(dataForURL url: URL) throws -> Data? { .none }
    
    func insert(_ data: Data, for url: URL) throws { }
}
