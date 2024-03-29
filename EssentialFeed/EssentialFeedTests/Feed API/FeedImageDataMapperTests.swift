//
//  FeedImageDataMapperTests.swift
//  EssentialFeedTests
//
//  Created by Ivo on 19/06/23.
//

import XCTest
import EssentialFeed

final class FeedImageDataMapperTests: XCTestCase {

    func test_map_deliversInvalidDataErrorOnNon200HTTPResponse() throws {
        let emptyJSON = Data("{[]}".utf8)
        
        let samples = [199, 201, 300, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(try FeedImageDataMapper.map(emptyJSON,
                                                             from: HTTPURLResponse(statusCode: code)))
        }
    }
    
    func test_map_deliversInvalidDataErrorOn200HTTPResponseWithEmptyData() throws {
        let emptyData = Data()
        
        XCTAssertThrowsError(try FeedImageDataMapper.map(emptyData,
                                                         from: HTTPURLResponse(statusCode: 200)))
    }
    
    func test_map_deliversReceivedNonEmptyDataOn200HTTPResponse() throws {
        let nonEmptyData = Data("non-empty data".utf8)
        
        let result = try FeedImageDataMapper.map(nonEmptyData, from: HTTPURLResponse(statusCode: 200))
        
        XCTAssertEqual(nonEmptyData, result)
    }

}
