//
//  SceneDelegate.swift
//  EssentialAppLegacy
//
//  Created by Ivo on 14/09/23.
//

import UIKit
import CoreData
import EssentialFeed

/* NOTE Scene Delegate for UI Testing
 
 The below configuration was changed so that it allowed DebbugingSceneDelegate
 
 1- LocalStoreURL
 2- makeRemoteClient
 
 */
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("legacy-feed-store.sqlite")
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(
            storeURL: localStoreURL)
    }()
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        configureWindow()
    }
    
    func configureWindow() {
        let remoteURL = URL(string: "https://static1.squarespace.com/static/5891c5b8d1758ec68ef5dbc2/t/5db4155a4fbade21d17ecd28/1572083034355/essential_app_feed.json")!
        
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        let feedLoader = FeedLoaderWithFallbackComposite(primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader,
                                                                                           cache: localFeedLoader),
                                                         fallback: localFeedLoader)
        let imageLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader,
                                                                   fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader,
                                                                                                               cache: localImageLoader))
        
        let feedViewController = FeedUIComposer.feedComposedWith(feedLoader: feedLoader,
                                                                 imageLoader: imageLoader)
        
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    // MARK: - Helpers
    
    func makeRemoteClient() -> HTTPClient {
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
    
    // makeRemoteClient vs private lazy var
//    private lazy var httpClient: HTTPClient = {
//        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
//    }()
}
