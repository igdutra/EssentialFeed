//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 03/04/23.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

final class FeedViewControllerTests: XCTest {
    
    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
}

// MARK: - Spy
extension FeedViewControllerTests {
    class LoaderSpy {
        private(set) var loadCallCount = 0
    }
}
