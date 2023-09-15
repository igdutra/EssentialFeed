//
//  EssentialAppLegacyUITests.swift
//  EssentialAppLegacyUITests
//
//  Created by Ivo on 14/09/23.
//

import XCTest

final class EssentialAppLegacyUITests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()
        
//        let feedCells = app.cells.matching(identifier: "feed-image-cell")
//        XCTAssertEqual(feedCells.count, 2)
//        
//        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
//        XCTAssertTrue(firstImage.exists)
    }
}
