//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Ivo on 26/04/23.
//

import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCacheAsync
    
    public init(decoratee: FeedLoader, cache: FeedCacheAsync) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            completion(result.map { feed in
                self?.cache.saveIgnoringResult(feed)
                return feed
            })
        }
    }
}

// NOTE: Code as documentation
private extension FeedCacheAsync {
    func saveIgnoringResult(_ feed: [FeedImage]) {
        save(feed) { _ in }
    }
}
