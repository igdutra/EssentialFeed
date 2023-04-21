//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ivo on 21/04/23.
//

import XCTest

class FeedImagePresenter {
    init(view: Any) {
        
    }
}

class FeedImagePresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
}

// MARK: - Spy
private extension FeedImagePresenterTests {
    class ViewSpy {
        let messages = [Any]()
    }
}

// MARK: - Helpers
private extension FeedImagePresenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedImagePresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
}
