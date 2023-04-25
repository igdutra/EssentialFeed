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

     init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {

     }

     func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
         return Task()
     }
 }

class FeedImageDataLoaderFallbackCompositeTests: XCTestCase {
    func test_init_doesNotLoadImageData() {
             let primaryLoader = LoaderSpy()
             let fallbackLoader = LoaderSpy()
             _ = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)

             XCTAssertTrue(primaryLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the primary loader")
             XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty, "Expected no loaded URLs in the fallback loader")
         }

    
    
    
    func test_load_deliversPrimaryFeedOnPrimaryLoaderSuccess() {
        let primaryFeed = anyData()
        let fallbackFeed = anyData()
        
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        let exp = expectation(description: "Wait for load completion")
        
        let expectedResult: FeedImageDataLoader.Result = .success(primaryFeed)
        _ = sut.loadImageData(from: URL(string: "test.com")!) { receivedResult in
            switch (receivedResult, expectedResult) {
            case let (.success(receivedFeed), .success(expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed)
                
            case (.failure, .failure):
                break
                
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(primaryResult: FeedImageDataLoader.Result, fallbackResult: FeedImageDataLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedImageDataLoader {
        let primaryLoader = ImageLoaderStub(result: primaryResult)
        let fallbackLoader = ImageLoaderStub(result: fallbackResult)
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
 
    private func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
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
