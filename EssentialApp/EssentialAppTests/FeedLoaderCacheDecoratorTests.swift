//
//  FeedLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Ivo on 26/04/23.
//

import XCTest
import EssentialFeed

protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>

    func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}

final class FeedLoaderCacheDecorator: FeedLoader {
    private let decoratee: FeedLoader
    private let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            if let feed = try? result.get() {
                self?.cache.save(feed) { _ in }
            }
            completion(result)
        }
    }
}

class FeedLoaderCacheDecoratorTests: XCTestCase, FeedLoaderTestCase {
    
    func test_load_deliversFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let sut = makeSUT(loaderResult: .success(feed))
        
        expect(sut, toCompleteWith: .success(feed))
    }
    
    func test_load_deliversErrorOnLoaderFailure() {
        let sut = makeSUT(loaderResult: .failure(anyNSError()))
        
        expect(sut, toCompleteWith: .failure(anyNSError()))
    }
    
    func test_load_cachesLoadedFeedOnLoaderSuccess() {
        let feed = uniqueFeed()
        let cache = CacheSpy()
        let sut = makeSUT(loaderResult: .success(feed), cache: cache)
        
        sut.load { _ in }
            
        XCTAssertEqual(cache.messages, [.save(feed: feed)], "Expected to cache loaded feed on success")
    }
    
    func test_load_doesNotCacheOnLoaderFailure() {
        let feed = uniqueFeed()
        let cacheSpy = CacheSpy()
        let sut = makeSUT(loaderResult: .failure(anyNSError()), cache: cacheSpy)
        
        sut.load { _ in }
        
        XCTAssertTrue(cacheSpy.messages.isEmpty)
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(loaderResult: FeedLoader.Result,
                         cache: CacheSpy = .init(),
                         file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let loader = FeedLoaderStub(result: loaderResult)
        let sut = FeedLoaderCacheDecorator(decoratee: loader, cache: cache)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private class CacheSpy: FeedCache {
        /* NOTE Enum Message vs direct array
         
         I think they opted to follow the enum message due to the fact that they don't need to worry about the completion
         
         */
        enum Message: Equatable {
            case save(feed: [EssentialFeed.FeedImage])
        }
        
        var messages: [Message] = .init()
        
        func save(_ feed: [EssentialFeed.FeedImage], completion: @escaping (FeedCache.Result) -> Void) {
            messages.append(.save(feed: feed))
        }
    }
}
