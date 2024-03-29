//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Ivo on 07/03/23.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase, FailableFeedStoreSpecs {
    
    // MARK: - Setup & Teardown
    override func setUp() {
        super.setUp()
        
        // This is self-docummenting code, repeting the function is better than writting a comment
        setupEmptyStoreState()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }
    
    // MARK:  Methods
    
    // MARK: - Retrieve
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversEmptyOnEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    // Old: test_retrieveAfterInsertingToEmptyCache_deliversInsertedValues
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on: sut)
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveDeliversFailureOnRetrievalError(on: sut)
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! "invalid data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        assertThatRetrieveHasNoSideEffectsOnFailure(on: sut)
    }
    
    // MARK: - Insert
    
    func test_insert_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_insert_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatInsertDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        assertThatInsertOverridesPreviouslyInsertedCacheValues(on: sut)
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertThatInsertDeliversErrorOnInsertionError(on: sut)
    }
    
    func test_insert_hasNoSideEffectsOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://store-url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        
        assertThatInsertHasNoSideEffectsOnInsertionError(on: sut)
    }
    
    
    // MARK: - Delete
    
    func test_delete_deliversNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnEmptyCache(on: sut)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteHasNoSideEffectsOnEmptyCache(on: sut)
    }
    
    func test_delete_deliversNoErrorOnNonEmptyCache() {
        let sut = makeSUT()
        
        assertThatDeleteDeliversNoErrorOnNonEmptyCache(on: sut)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        
        assertThatDeleteEmptiesPreviouslyInsertedCache(on: sut)
    }
    
    func test_delete_deliversErrorOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertThatDeleteDeliversErrorOnDeletionError(on: sut)
    }
    
    // TODO: WATCH HERE
    // https://academy.essentialdeveloper.com/courses/447455/lectures/10675368/comments/7321729
    
    // Test Case '-[EssentialFeedTests.CodableFeedStoreTests test_delete_deliversErrorOnDeletionError]' passed (2.212 seconds)
    // I wanted to know why this cache test is taking that long, but it was nice to mesure it anyway!
    // Had to change the expectation to 5.0
    /*
     However, in the CI gitHubActions:
     /Users/runner/work/EssentialFeed/EssentialFeed/EssentialFeedTests/Feed Cache/FeedStoreSpecs/XCTestCase+FeedStoreSpecs.swift:139: error: -[EssentialFeedTests.CodableFeedStoreTests test_delete_hasNoSideEffectsOnDeletionError] : Asynchronous wait failed: Exceeded timeout of 5 seconds, with unfulfilled expectations: "Wait for cache deletion".
     898
     Test Case '-[EssentialFeedTests.CodableFeedStoreTests test_delete_hasNoSideEffectsOnDeletionError]' failed (9.509 seconds).
     ALMOST 10 SECONDS. SOMETHING IS OFF.
     
     after trying real hard we saw that that's it, it takes simply to long to verify that we don't have permission to delete.. not my focus now to think of a workaround so lets just set timeout to 15s and let this big warning here!
     
     there is a comment saying that had the same problem as I did, so Investigate it!
     */
    func test_delete_hasNoSideEffectsOnDeletionError() {
        let noDeletePermissionURL = noDeletePermissionURL()
        let sut = makeSUT(storeURL: noDeletePermissionURL)
        
        assertThatDeleteHasNoSideEffectsOnDeletionError(on: sut)
    }
    
    
    // MARK: - Thread Test
    // Test disabled since Core Data implementation is now sync
//    func test_storeSideEffects_runSerially() {
//        let sut = makeSUT()
//        
//        assertThatSideEffectsRunSerially(on: sut)
//    }
}

// MARK: - Helpers

private extension CodableFeedStoreTests {
    // Cannot use functions as default parameters
    func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let storeURL = storeURL ?? testSpecificStoreURL()
        let sut = CodableFeedStore(storeURL: storeURL)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    func setupEmptyStoreState() {
        deleteStoreArtifacts()
    }
    
    func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL())
    }
    
    func testSpecificStoreURL() -> URL {
        // file:///Users/ivo/Library/Caches/CodableFeedStoreTests.store
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    // For the iOS Only ->
    // The cache directory permission is different in the iOS simulator (you can delete the directory on the simulator, but not on the macOS target!). 
    private func noDeletePermissionURL() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
}
