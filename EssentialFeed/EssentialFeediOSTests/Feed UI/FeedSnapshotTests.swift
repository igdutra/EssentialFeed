//
//  FeedSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 27/04/23.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class FeedSnapshotTests: XCTestCase {
    
    /* NOTE
     
     1 - first record the view using
     record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
     
     2- Once recorded, assert it
     assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
     
     3 - Recorded using iPhone 14 iOS 16.4 Simulator
     
     */
    
    /* NOTE: why I disbled these tests
     // Deactivate snapshot tests until further investigation.
     // Error view is now acting as it should but tests are still failing.
     - For feed this is causing a LARGE empty space and pushing content further down.
     - but the app runs fine
     - see extra large snapshot test. the frame might be updating after the test
     
     Solution:
     - ErrorView tests are now running fine
     - This LARGE empty space is acceptable at the snapshot since I compared them with the ones provided by the ImageCommentsChallenge. So I'll be recording new ones and asserting them against it.
     */
    
    func test_feedWithContent() {
        let sut = makeSUT()
        
        sut.display(feedWithContent())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_CONTENT_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_CONTENT_dark")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light,
                                                    contentSize: .extraExtraLarge)),
               named: "FEED_WITH_CONTENT_light_extraExtraLarge")
    }
    
    func test_feedWithFailedImageLoading() {
        let sut = makeSUT()
        
        sut.display(feedWithFailedImageLoading())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_FAILED_IMAGE_LOADING_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_FAILED_IMAGE_LOADING_dark")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light,
                                                    contentSize: .extraExtraLarge)),
               named: "FEED_WITH_FAILED_IMAGE_LOADING_light_extraExtraLarge")
    }
    
    func test_feedWithLoadMoreIndicator() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreIndicator())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_INDICATOR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_INDICATOR_dark")
    }
    
    func test_feedWithLoadMoreError() {
        let sut = makeSUT()
        
        sut.display(feedWithLoadMoreError())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_LOAD_MORE_ERROR_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_LOAD_MORE_ERROR_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_LOAD_MORE_ERROR_extraExtraExtraLarge")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let controller = storyboard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func feedWithContent() -> [ImageStub] {
        return [
            ImageStub(
                description: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                location: "East Side Gallery\nMemorial in Berlin, Germany",
                image: UIImage.make(withColor: .red)
            ),
            ImageStub(
                description: "Garth Pier is a Grade II listed structure in Bangor, Gwynedd, North Wales.",
                location: "Garth Pier",
                image: UIImage.make(withColor: .green)
            )
        ]
    }
    
    private func feedWithFailedImageLoading() -> [ImageStub] {
        return [
            ImageStub(
                description: nil,
                location: "Cannon Street, London",
                image: nil
            ),
            ImageStub(
                description: nil,
                location: "Brighton Seafront",
                image: nil
            )
        ]
    }
    
    private func feedWithLoadMoreIndicator() -> [CellController] {
        let loadMore = LoadMoreCellController(callback: {})
        loadMore.display(ResourceLoadingViewModel(isLoading: true))
        return feedWith(loadMore: loadMore)
    }
    
    private func feedWithLoadMoreError() -> [CellController] {
        let loadMore = LoadMoreCellController(callback: {})
        loadMore.display(ResourceErrorViewModel(message: "This is a multiline\nerror message"))
        return feedWith(loadMore: loadMore)
    }
    
    private func feedWith(loadMore: LoadMoreCellController) -> [CellController] {
        let stub = feedWithContent().last!
        let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: {})
        stub.controller = cellController
        
        return [
            CellController(id: UUID(), cellController),
            CellController(id: UUID(), loadMore)
        ]
    }
}

// MARK: - Stubs

private extension ListViewController {
    func display(_ stubs: [ImageStub]) {
        let cells: [CellController] = stubs.map { stub in
            let cellController = FeedImageCellController(viewModel: stub.viewModel, delegate: stub, selection: { })
            stub.controller = cellController
            return CellController(id: UUID(), cellController)
        }
        
        display(cells)
    }
}

private class ImageStub: FeedImageCellControllerDelegate {
    let viewModel: FeedImageViewModel
    let image: UIImage?
    weak var controller: FeedImageCellController?
    
    init(description: String?, location: String?, image: UIImage?) {
        self.viewModel = FeedImageViewModel(description: description,
                                            location: location)
        self.image = image
    }
    
    func didRequestImage() {
        controller?.display(ResourceLoadingViewModel(isLoading: false))
        
        if let image = image {
            controller?.display(image)
            controller?.display(ResourceErrorViewModel(message: .none))
        } else {
            controller?.display(ResourceErrorViewModel(message: "any"))
        }
    }
    
    func didCancelImageRequest() {}
}
