//
//  FeedAcceptanceTests.swift
//  EssentialAppTests
//
//  Created by Ivo on 26/04/23.
//

import XCTest
import EssentialFeed
import EssentialFeediOS
@testable import EssentialApp

class FeedAcceptanceTests: XCTestCase {
    
    func test_onLaunch_displaysRemoteFeedWhenCustomerHasConnectivity() {
        let feed = launch(httpClient: .online(response), store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(feed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(feed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysCachedRemoteFeedWhenCustomerHasNoConnectivity() {
        let sharedStore = InMemoryFeedStore.empty
        let onlineFeed = launch(httpClient: .online(response), store: sharedStore)
        onlineFeed.simulateFeedImageViewVisible(at: 0)
        onlineFeed.simulateFeedImageViewVisible(at: 1)
        
        let offlineFeed = launch(httpClient: .offline, store: sharedStore)
        
        XCTAssertEqual(offlineFeed.numberOfRenderedFeedImageViews(), 2)
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 0), makeImageData())
        XCTAssertEqual(offlineFeed.renderedFeedImageData(at: 1), makeImageData())
    }
    
    func test_onLaunch_displaysEmptyFeedWhenCustomerHasNoConnectivityAndNoCache() {
        let feed = launch(httpClient: .offline, store: .empty)
        
        XCTAssertEqual(feed.numberOfRenderedFeedImageViews(), 0)
    }
    
    func test_onEnteringBackground_deletesExpiredFeedCache() throws {
        let store = InMemoryFeedStore.withExpiredFeedCache
        
        try enterBackground(with: store)
        
        XCTAssertNil(store.feedCache, "Expected to delete expired cache")
    }
    
    func test_onEnteringBackground_keepsNonExpiredFeedCache() throws {
        let store = InMemoryFeedStore.withNonExpiredFeedCache
        
        try enterBackground(with: store)
        
        XCTAssertNotNil(store.feedCache, "Expected to keep non-expired cache")
    }
    
    // MARK: - Helpers
    
    private func launch(
        httpClient: HTTPClientStub = .offline,
        store: InMemoryFeedStore = .empty
    ) -> FeedViewController {
        let sut = SceneDelegate(httpClient: httpClient, store: store)
        sut.window = UIWindow()
        sut.configureWindow()
        
        let nav = sut.window?.rootViewController as? UINavigationController
        return nav?.topViewController as! FeedViewController
    }
    

    /* NOTE Fixing flaky FeedAcceptanceTests.test_onEnteringBackground_deletesExpiredFeedCache
     
     IMO, the test_onEnterinaBackaround_keepsExpiredFeedCache runs too early and the scene was not loaded properly yet, so there is no connectedScenes. first. By the time test_onEnteringBackaround_deletesNonExpiredFeedCacheruns, the scene is loaded. I would try running the build a few more times on Cl, see if it still fails in the same way (I see just 2 runs), just to make sure it's not a Cl machine load that caused this.
     
     This is how to instantiate the UIScene so you don't need to force-unwrap the optional connectScenes.first
     */
//    private func enterBackground(with store: InMemoryFeedStore) {
//        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)
//        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
//    }
    private func enterBackground(with store: InMemoryFeedStore) throws {
        let sut = SceneDelegate(httpClient: HTTPClientStub.offline, store: store)

        let sceneClass = NSClassFromString("UIScene") as? NSObject.Type
        let scene = try XCTUnwrap(sceneClass?.init() as? UIScene)
        sut.sceneWillResignActive(scene)
    }
    
    private func response(for url: URL) -> (Data, HTTPURLResponse) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        return (makeData(for: url), response)
    }
    
    private func makeData(for url: URL) -> Data {
        switch url.absoluteString {
        case "http://image.com":
            return makeImageData()
            
        default:
            return makeFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        return UIImage.make(withColor: .red).pngData()!
    }
    
    private func makeFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items": [
            ["id": UUID().uuidString, "image": "http://image.com"],
            ["id": UUID().uuidString, "image": "http://image.com"]
        ]])
    }
}
