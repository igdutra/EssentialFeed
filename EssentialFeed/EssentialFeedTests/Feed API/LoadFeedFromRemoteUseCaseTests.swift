//
//  RemoteFeedLoaderTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 19/11/22.
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
    // This was a request in the user story
    func test_load_deliversErrorOnNon200HTTPResponse() {
        let (sut, client) = makeSUT()
        
        let samples = [199, 201, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut,
                   toCompleteWithResut: failure(.invalidData),
                   when: {
                let json = emptyJSON()
                client.complete(withStatusCode: code, data: json, at: index)
            })
        }
    }
    
    func test_load_whenHTTPResponseIs200_deliversError() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithResut: failure(.invalidData),
               when: {
            let invalidJSON = invalidJSON()
            client.complete(withStatusCode: 200, data: invalidJSON)
        })
    }
    
    func test_load_Success_whenHTTPResponseIs200AndEmptyJson() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithResut: .success([]),
               when: {
            let emptyJSON = makeFeed(items: [])
            client.complete(withStatusCode: 200, data: emptyJSON)
        })
    }
    
    func test_load_whenHTTPResponseIs200_deliversItemsArray() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(id: UUID(), description: "A description", location: "A location", url: anyURL())
        let item2 = makeItem(id:  UUID(), url: anyURL("anotherURL"))
        let items = [item1.model, item2.model]
        
        expect(sut,
               toCompleteWithResut: .success(items),
               when: {
            let finalJSON = makeFeed(items: [item1.json, item2.json])
            client.complete(withStatusCode: 200, data: finalJSON)
        })
    }
}

// MARK: - Helpers
private extension LoadFeedFromRemoteUseCaseTests {
    
    func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        .failure(error)
    }
    
    // MARK: Factories
    
    func makeSUT(url: URL = URL(string: "a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader,
                                                                                                           client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    func expect(_ sut: RemoteFeedLoader,
                toCompleteWithResut expectedResult: RemoteFeedLoader.Result,
                when action: () -> Void,
                file: StaticString = #filePath, line: UInt = #line) {
        let exp = expectation(description: "Wait for load completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedItems), .success(let expectedItems)):
                print()
                XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)
            case (.failure(let receivedError as RemoteFeedLoader.Error), .failure(let expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
                
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: Stubs
    
    func makeItem(id: UUID, description: String? = nil, location: String? = nil, url: URL) -> (model: FeedImage, json: [String: Any]) {
        let item = FeedImage(id: id, description: description, location: location, url: url)
        
        let itemJSON = [
            "id": item.id.uuidString,
            "description": item.description,
            "location": item.location,
            "image": item.url.absoluteString
        ].compactMapValues { $0 }
        // Note: Before swift 5
        /*
         reduce(into: [String: Any]()) { (acc, e) in
                      if let value = e.value { acc[e.key] = value }
                  }
         // credo
         */
        
        return (item, itemJSON)
    }
    
    func makeFeed(items: [[String: Any]]) -> Data {
        let feed = ["items": items]
        return try! JSONSerialization.data(withJSONObject: feed)
    }
        
    func invalidJSON() -> Data {
        Data("invalid json".utf8)
    }
    
    func emptyJSON() -> Data {
        Data("{[]}".utf8)
    }
}
