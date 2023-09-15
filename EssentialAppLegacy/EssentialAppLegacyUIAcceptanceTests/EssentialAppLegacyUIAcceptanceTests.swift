//
//  EssentialAppLegacyUIAcceptanceTests.swift
//  EssentialAppLegacyUIAcceptanceTests
//
//  Created by Ivo on 15/09/23.
//

import XCTest

// Note: This UI test did not required a Test Plan since it's the only one in it's own target.
// Testplan was required for EssentialAppLegacyTests

/* NOTE Observations in UI Testing
 
    Blackbox testing
 Since we don't have control of the internal details, it is very easy for one test affect the other.
 That's why there's the -reset flag in each of them.

    Possible improvements
 Maybe do some dictionary holding references to the Accessibility labels (static enum containing it
 OR that the default identifier is the class name + "accessibilityIdentifier" can create a free function that does that.
 
 Also an enum holding static properties to the launchArguments is a good option.

 */
final class EssentialAppUIAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()
        
        // Use Accessibility Identifiers
        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 2)
        
        // Assert that there's at least 1 visible image
        //   on the iphone 14 there are 2, however depending on the screen size it could show only one
        let firstImage = app.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstImage.exists)
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset", "-connectivity", "online"]
        onlineApp.launch()

        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()

        let cachedFeedCells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cachedFeedCells.count, 2)
        
        let firstCachedImage = offlineApp.images.matching(identifier: "feed-image-view").firstMatch
        XCTAssertTrue(firstCachedImage.exists)
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "offline"]
        app.launch()

        let feedCells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(feedCells.count, 0)
    }
}
