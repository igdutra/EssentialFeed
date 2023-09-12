//
//  LocalFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Ivo on 24/04/23.
//


import Foundation

public final class LocalFeedImageDataLoader {
    private let store: FeedImageDataStore
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
}

extension LocalFeedImageDataLoader: FeedImageDataCache { 
    public enum SaveError: Error {
        case failed
    }
    
    public func save(_ data: Data, for url: URL) throws {
        do {
            try store.insert(data, for: url)
        } catch {
            throw SaveError.failed
        }
    }
}

extension LocalFeedImageDataLoader: FeedImageDataLoader {    
    public enum LoadError: Error {
        case failed
        case notFound
    }
    
    public func loadImageData(from url: URL) throws -> Data {
         do {
             if let imageData = try store.retrieve(dataForURL: url) {
                 return imageData
             }
         } catch {
             throw LoadError.failed
         }

         throw LoadError.notFound
     }
    
    // MARK: - Deleted
    // Note: no Need for FeedImageDataLoaderTask anymore
    // Deleted functions
    public typealias LoadResult = FeedImageDataLoader.Result
    private final class LoadImageDataTask: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?

        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (LoadResult) -> Void) -> FeedImageDataLoaderTask {
        let task = LoadImageDataTask(completion)
        return task
    }
}
