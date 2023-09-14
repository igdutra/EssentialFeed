//
//  FeedImageDataLoader.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import Foundation

public protocol FeedImageDataLoader {
    func loadImageData(from url: URL) throws -> Data
    
    // Deleted -> could create another type to avoid confusion
    typealias Result = Swift.Result<Data, Error>
    func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

// Note: we win the cancel for free in the composition root
// Keeping it for the RemoteFeedLoader (old)
public protocol FeedImageDataLoaderTask {
    func cancel()
}
