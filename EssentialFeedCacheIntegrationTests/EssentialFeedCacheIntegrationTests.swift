//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Ivo on 09/03/23.
//

import XCTest
import EssentialFeed

// TODO: The CoreData implementation will be done in the challenge.
// I'll first read a bit about CoreData, read the challenge, only then copy the coreData implementation to this project.

final class EssentialFeedCacheIntegrationTests: XCTestCase {
    func test_load_deliversNoItemsOnEmptyCache() {
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        sut.load { result in
            switch result {
            case let .success(imageFeed):
                XCTAssertEqual(imageFeed, [], "Expected empty feed")
                
            case let .failure(error):
                XCTFail("Expected successful feed result, got \(error) instead")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
}

// MARK: - Helpers

private extension EssentialFeedCacheIntegrationTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        //        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = testSpecificStoreURL()
        //        let store = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        let store = CodableFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func testSpecificStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
