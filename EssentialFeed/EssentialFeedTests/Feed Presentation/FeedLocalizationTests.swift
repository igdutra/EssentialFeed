//
//  FeedLocalizationTests.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 14/04/23.
//

import XCTest
@testable import EssentialFeed

final class FeedLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        
        assertLocalizedKeyAndValuesExists(in: bundle, table)
    }
}
