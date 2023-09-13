//
//  CoreDataFeedStore+FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ivo on 24/04/23.
//

import CoreData

extension CoreDataFeedStore: FeedImageDataStore {
    
    public func insert(_ data: Data, for url: URL) throws {
        try performSync { context in
            Result {
                try ManagedFeedImage.first(with: url, in: context) // Returns an image
                    .map { $0.data = data } // The image.data equals the found data
                    .map(context.save) // Unwrap using map
            }
        }
    }
    
    public func retrieve(dataForURL url: URL) throws -> Data? {
        try performSync { context in
            Result {
                try ManagedFeedImage.data(with: url, in: context)
            }
        }
    }
}

// MARK: - Async

extension CoreDataFeedStore: FeedImageDataStoreAsync {
    
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStoreAsync.InsertionResult) -> Void) {
        performAsync { context in
            completion(Result {
                try ManagedFeedImage.first(with: url, in: context) // Returns an image
                     .map { $0.data = data } // The image.data equals the found data
                     .map(context.save) // Unwrap using map
            })
        }
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStoreAsync.RetrievalResult) -> Void) {
        performAsync { context in
            completion(Result {
                try ManagedFeedImage.data(with: url, in: context)
            })
        }
    }
}
