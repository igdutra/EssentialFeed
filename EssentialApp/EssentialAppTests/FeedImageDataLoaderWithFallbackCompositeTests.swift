//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Ivo on 25/04/23.
//

import XCTest
import EssentialFeed

class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    private let primary: FeedImageDataLoader
    
    init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        _ = primary.loadImageData(from: url) { _ in }
        return Task()
    }
}

class FeedImageDataLoaderFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL()
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(primaryLoader.loadedURLs, [url], "Expected to load URL from primary loader")
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
    }
    
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = anyData()
        let fallbackFeed = anyData()
        
//        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
//        
//        let exp = expectation(description: "Wait for load completion")
//        
//        let expectedResult: FeedImageDataLoader.Result = .success(primaryFeed)
//        _ = sut.loadImageData(from: URL(string: "test.com")!) { receivedResult in
//            switch (receivedResult, expectedResult) {
//            case let (.success(receivedFeed), .success(expectedFeed)):
//                XCTAssertEqual(receivedFeed, expectedFeed)
//                
//            case (.failure, .failure):
//                break
//                
//            default:
//                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
//            }
//            
//            exp.fulfill()
//        }
//        
//        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImageDataLoader, primary: LoaderSpy, fallback: LoaderSpy) {
             let primaryLoader = LoaderSpy()
             let fallbackLoader = LoaderSpy()
             let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
             trackForMemoryLeaks(primaryLoader, file: file, line: line)
             trackForMemoryLeaks(fallbackLoader, file: file, line: line)
             trackForMemoryLeaks(sut, file: file, line: line)
             return (sut, primaryLoader, fallbackLoader)
         }
    
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://a-url.com")!
    }
    
    
    private class ImageLoaderStub: FeedImageDataLoader {
        private struct Task: FeedImageDataLoaderTask {
            let callback: () -> Void
            func cancel() { callback() }
        }
        
        private let result: FeedImageDataLoader.Result
        
        init(result: FeedImageDataLoader.Result) {
            self.result = result
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> EssentialFeed.FeedImageDataLoaderTask {
            return Task {
                completion(self.result)
            }
        }
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() {}
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }
}
