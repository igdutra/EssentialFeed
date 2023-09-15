//
//  EssentialAppLegacyUIAcceptanceTests.swift
//  EssentialAppLegacyUIAcceptanceTests
//
//  Created by Ivo on 15/09/23.
//

import XCTest

final class EssentialAppLegacyUIAcceptanceTests: XCTestCase {

    func test_TDD_SceneDelegate_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
         let app = XCUIApplication()

         app.launch()

         XCTAssertEqual(app.cells.count, 22)
        // Assert that there's at least 1 visible image
        //   on the iphone 14 there are 2, however depending on the screen size it could show only one
         XCTAssertEqual(app.cells.firstMatch.images.count, 1)
     }

}
