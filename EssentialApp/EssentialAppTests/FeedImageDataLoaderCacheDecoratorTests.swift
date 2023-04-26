//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Ivo on 26/04/23.
//

import Foundation
import XCTest
import EssentialFeed

final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: completion)
    }
}

final class FeedImageDataLoaderCacheDecoratorTests: XCTestCase {
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let data = anyData()
        let url = anyURL()
        let loaderSpy = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy)
        
        _ = sut.loadImageData(from: url) { _ in }
        loaderSpy.complete(with: data)
        
        XCTAssertEqual(loaderSpy.loadedURLs, [url], "Expected to load URL from loader")
    }

    func test_loadImageData_deliversDataOnLoaderSuccess2() {
        let data = anyData()
        let url = anyURL()
        let loaderSpy = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy)
        
        expect(sut,
               toCompleteWith: .success(data),
               when: {
            loaderSpy.complete(with: data)
        })
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let error = anyNSError()
        let loaderSpy = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loaderSpy)
        
        expect(sut,
               toCompleteWith: .failure(error),
               when: {
            loaderSpy.complete(with: error)
        })
    }
    
    // MARK: - Helpers
    
    private func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        _ = sut.loadImageData(from: anyURL()) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
//
        private(set) var cancelledURLs = [URL]()
        
        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        private struct Task: FeedImageDataLoaderTask {
            // Note: The callback is to make sure, when called cancel, to append the cancelled URL at the canceled array.
//            let callback: () -> Void
            func cancel() { }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }
}
