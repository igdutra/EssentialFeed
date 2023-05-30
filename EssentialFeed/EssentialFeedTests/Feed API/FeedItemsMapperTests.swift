//
//  FeedItemsMapperTests.swift
//  EssentialFeedTests
//
//  Created by Ivo on 29/05/23.
//

import XCTest
import EssentialFeed

final class FeedItemsMapperTests: XCTestCase {
    
    func test_map_deliversErrorOnNon200HTTPResponse() throws {
        let json = emptyJSON()
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try FeedItemsMapper.map(json, from: HTTPURLResponse(statusCode: code))
            )
        }
    }
    
    func test_map_throwsErrorOn200HTTPResponseWithInvalidJSON() throws {
        let invalidJSON = invalidJSON()
        
        XCTAssertThrowsError(
            try FeedItemsMapper.map(invalidJSON, from: HTTPURLResponse(statusCode: 200))
        )
    }
    
    func test_map_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() throws {
        let emptyJSON = makeFeedJSON(items: [])
        
        let result = try FeedItemsMapper.map(emptyJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, [])
    }
    
    func test_map_whenHTTPResponseIs200_deliversItemsArray() throws {
        let item1 = makeItem(id: UUID(), description: "A description", location: "A location", url: anyURL())
        let item2 = makeItem(id:  UUID(), url: anyURL("anotherURL"))
        let finalJSON = makeFeedJSON(items: [item1.json, item2.json])
        let expectedItems = [item1.model, item2.model]
       
        
        let result = try FeedItemsMapper.map(finalJSON, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(result, expectedItems)
    }
}

// MARK: - Helpers
private extension FeedItemsMapperTests {
    
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
        
    func invalidJSON() -> Data {
        Data("invalid json".utf8)
    }
    
    func emptyJSON() -> Data {
        Data("{[]}".utf8)
    }
}
