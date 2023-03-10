//
//  RemoteFeedLoaderTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 19/11/22.
//

import XCTest
import EssentialFeed

final class LoadFeedFromRemoteUseCaseTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "a-different-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataFromURLTwice() {
        let url = URL(string: "a-different-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut,
               toCompleteWithResut: failure(.connectivity),
               when: {
            let clientError = NSError(domain: "Test", code: 0)
            client.complete(with: clientError)
        })
    }
    
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
    
    // Instances are deallocated and some strange behavior starts to happen.
    // This test is to documment the guard self != nil else { return }
    func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = anyURL()
        // Make SUT has teardown block and sut is not optional
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        
        var capturedResults: [RemoteFeedLoader.Result?] = []
        sut?.load { capturedResults.append($0) }
        
        sut = nil
        client.complete(withStatusCode: 20, data: emptyJSON())
        
        print(capturedResults)
        
        XCTAssertTrue(capturedResults.isEmpty)
    }
}

// MARK: - Spy
private extension LoadFeedFromRemoteUseCaseTests {
    class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        // This way you don't break the current tests
        var requestedURLs: [URL] {
            messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(withStatusCode code: Int,
                      data: Data,
                      at index: Int = 0) {
            let response = HTTPURLResponse(url: requestedURLs[index],
                                           statusCode: code,
                                           httpVersion: nil,
                                           headerFields: nil)!
            
            messages[index].completion(.success((data, response)))
        }
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
