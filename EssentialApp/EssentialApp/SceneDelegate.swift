//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Ivo on 25/04/23.
//

import UIKit
import CoreData
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    /* NOTE Lazy instantiation
     
     If they are not set, we have a chance of instantiating them lazyly
     
     So lazy vars is our recommended way of creating expensive dependencies like CoreData instances that need to open DB connections and load data from disk.
     This way, you only run expensive operations when really needed.
     
     */
    
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL: localStoreURL)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localFeedLoader = LocalFeedLoader(store: store, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        let feedLoader = FeedLoaderWithFallbackComposite(primary: FeedLoaderCacheDecorator(decoratee: remoteFeedLoader,
                                                                                           cache: localFeedLoader),
                                                         fallback: localFeedLoader)
        let imageLoader = FeedImageDataLoaderWithFallbackComposite(primary: localImageLoader,
                                                                   fallback: FeedImageDataLoaderCacheDecorator(decoratee: remoteImageLoader,
                                                                                                               cache: localImageLoader))
        
        window?.rootViewController = UINavigationController(rootViewController:
                                                                FeedUIComposer.feedComposedWith(feedLoader: feedLoader,
                                                                                                imageLoader: imageLoader))
    }
    
    func makeRemoteClient() -> HTTPClient {
        return httpClient
    }
}
