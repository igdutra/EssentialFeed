//
//  ImageCommentsLocalizationTests.swift
//  EssentialFeedTests
//
//  Created by Ivo on 03/07/23.
//

import XCTest
import EssentialFeed

final class ImageCommentsLocalizationTests: XCTestCase {
    
    func test_localizedStrings_haveKeysAndValuesForAllSupportedLocalizations() {
        let table = "ImageComments"
        let bundle = Bundle(for: ImageCommentsPresenter.self)
        
        assertLocalizedKeyAndValuesExists(in: bundle, table)
    }
}
