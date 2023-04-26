//
//  EssentialAppUITests.swift
//  EssentialAppUITests
//
//  Created by Ivo on 26/04/23.
//

import XCTest

final class EssentialAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()

        app.launch()

        XCTAssertEqual(app.cells.count, 22)
        // Failing Test, 0 Images. Let's move on
        XCTAssertEqual(app.cells.firstMatch.images.count, 1)
    }
}
