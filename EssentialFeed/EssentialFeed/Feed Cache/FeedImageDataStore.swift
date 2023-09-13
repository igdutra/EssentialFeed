//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ivo on 24/04/23.
//

import Foundation

public protocol FeedImageDataStore {
    func insert(_ data: Data, for url: URL) throws
    func retrieve(dataForURL url: URL) throws -> Data?
}
 
// Note: FeedImageDataStoreAsync was the old way, deleted.
// Keeping for Reference.
public protocol FeedImageDataStoreAsync {
    typealias RetrievalResult = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (RetrievalResult) -> Void)
}
