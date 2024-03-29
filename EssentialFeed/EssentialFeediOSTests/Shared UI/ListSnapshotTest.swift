//
//  ListSnapshotTest.swift
//  EssentialFeediOSTests
//
//  Created by Ivo on 04/07/23.
//

import XCTest
import EssentialFeediOS

final class ListSnapshotTest: XCTestCase {

    /* NOTE
     
     1 - first record the view using
     record(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
     
     2- Once recorded, assert it
     assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
     
     */
    
    func test_emptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_LIST_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_LIST_dark")
    }
    
    /* NOTE why I temporarily disabled this test
     
     Disabling this test since is the only snapshot failing, even when i'm using
     Xcode14.2 + Iphone 14 - iOS 16.2
     
     THE SNAPSHOT WILL PASS ONLY when activated the tolerance! if !match(snapshotData, storedSnapshotData, tolerance: 0.00001)
     
     NOTE 2: Why I disabled this test for 2nd time
     Error view is now acting as it should but tests are still failing.
      - Background error color was wrong
      - Label was not set to white.
      - There was not top/bottom space
     Fixed when implemented contentSize feature.
     */

    func test_listWithErrorMessage() {
        let sut = makeSUT()

        sut.display(.error(message: "This is a\nmulti-line\nerror message"))

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "LIST_WITH_ERROR_MESSAGE_light")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "LIST_WITH_ERROR_MESSAGE_dark")
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light,
                                                    contentSize: .extraExtraExtraLarge)),
               named: "LIST_WITH_ERROR_MESSAGE_light_extraExtraExtraLarge")
    }
    
    // MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private func emptyFeed() -> [CellController] {
        return []
    }
}
