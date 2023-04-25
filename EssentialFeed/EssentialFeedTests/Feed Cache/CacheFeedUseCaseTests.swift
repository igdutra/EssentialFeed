//
//  CacheFeedUseCaseTests.swift
//  Persistence-EssentialsTests
//
//  Created by Ivo on 21/12/22.
//

import XCTest
import Network
import EssentialFeed

// MARK: - Tests

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_requestsCacheDeletion() {
        let (sut, store) = makeSUT()
        
        sut.save(makeImages().models) { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_doesNotRequestCacheInsertionOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        sut.save(makeImages().models) { _ in}
        store.completeDeletion(with: deletionError)
        
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed])
    }
    
    func test_save_requestsNewCacheInsertionWithTimestampOnSuccessfulDeletion() {
        let timestamp = Date()
        let images = makeImages()
        let (sut, store) = makeSUT(currentDate: { timestamp })
        
        sut.save(images.models) { _ in }
        store.completeDeletionSuccessfully()
        
        // Although I can argue here that this is the only place where local is being used, so maybe that abstraction could remain only here
        XCTAssertEqual(store.receivedMessages, [.deleteCachedFeed, .insert(feed: images.local, timestamp: timestamp)])
    }
    
    func test_save_failsOnDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut,
               toCompleteWithError: deletionError,
               when: {
            store.completeDeletion(with: deletionError)
        })
    }
    
    
    func test_save_failsOnInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = anyNSError()
       
        expect(sut,
               toCompleteWithError: insertionError,
               when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_succeedsOnSuccessfulCacheInsertion() {
        let (sut, store) = makeSUT()
        
        expect(sut,
               toCompleteWithError: nil,
               when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func test_save_doesNotDeliverDeletionErrorAfterSUTInstanceHasBeenDeallocated() {
         let store = FeedStoreSpy()
         var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

         var receivedResults = [LocalFeedLoader.SaveResult]()
         sut?.save(makeImages().models) { receivedResults.append($0) }

         sut = nil
         store.completeDeletion(with: anyNSError())

         XCTAssertTrue(receivedResults.isEmpty)
     }
    
    func test_save_doesNotDeliverInsertionErrorAfterSUTInstanceHasBeenDeallocated() {
         let store = FeedStoreSpy()
         var sut: LocalFeedLoader? = LocalFeedLoader(store: store, currentDate: Date.init)

         var receivedResults = [LocalFeedLoader.SaveResult]()
         sut?.save(makeImages().models) { receivedResults.append($0) }

         store.completeDeletionSuccessfully()
         sut = nil
         store.completeInsertion(with: anyNSError())

         XCTAssertTrue(receivedResults.isEmpty)
     }
}

// MARK: - Helpers

private extension CacheFeedUseCaseTests {
    func makeSUT(currentDate: @escaping () -> Date = Date.init,
                 file: StaticString = #file, line: UInt = #line)
    -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, store)
    }
    
    func expect(_ sut: LocalFeedLoader,
                toCompleteWithError expectedError: NSError?,
                when action: () -> Void,
                file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for save completion")
        
        var receivedError: Error?
        sut.save(makeImages().models) { result in
            if case let Result.failure(error) = result { receivedError = error }
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receivedError as NSError?, expectedError, file: file, line: line)
    }
    
    // MARK: Stubs
    
    func makeImages() -> (models: [FeedImage], local: [LocalFeedImage]) {
        let uniqueImage1 = FeedImage(id: UUID(), url: anyURL())
        let uniqueImage2 = FeedImage(id: UUID(), url: anyURL())
        
        let images = [uniqueImage1, uniqueImage2]
        let local = images.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
        
        return (images, local)
    }
}
