//
//  FeedPresenterTests.swift
//  EssentialFeedTests
//
//  Created by Ivo on 21/04/23.
//

import XCTest

struct FeedErrorViewData {
    let message: String?

    static var noError: FeedErrorViewData {
        return FeedErrorViewData(message: nil)
    }
}

protocol FeedErrorView {
    func display(_ viewModel: FeedErrorViewData)
}

final class FeedPresenter {
    private let errorView: FeedErrorView
    
    init(errorView: FeedErrorView) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

class FeedPresenterTests: XCTestCase {
    
    func test_init_doesNotSendMessagesToView() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty, "Expected no view messages")
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }
    
    // MARK: - Helpers
    
    private class ViewSpy: FeedErrorView {
        /* NOTE Message Array
         
         So use it but to avoid confromance with Equatable, just use the elements inside the viewModel not
         the complete method signture
         
         */
        enum Message: Equatable {
            case display(errorMessage: String?)
        }
        
        private(set) var messages = [Message]()
        
        func display(_ viewModel: FeedErrorViewData) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}

// MARK: - Helpers
private extension FeedPresenterTests {
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedPresenter, view: ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(errorView: view)
        trackForMemoryLeaks(view, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, view)
    }
}
