//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ivo on 21/04/23.
//

import XCTest

final class FeedPresenter {
    init(view: Any) {
        
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    // MARK: - Helpers
    
    private class ViewSpy {
        let messages = [Any]()
    }
    
}

// MARK: - Helpers
private extension FeedPresenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
         let view = ViewSpy()
         let sut = FeedPresenter(view: view)
         trackForMemoryLeaks(view, file: file, line: line)
         trackForMemoryLeaks(sut, file: file, line: line)
         return (sut, view)
     }
}
