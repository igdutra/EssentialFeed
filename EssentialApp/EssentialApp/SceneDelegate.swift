//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Ivo on 25/04/23.
//

import UIKit
import CoreData
import Combine
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    /* NOTE Lazy instantiation
     
     If they are not set, we have a chance of instantiating them lazyly
     
     So lazy vars is our recommended way of creating expensive dependencies like CoreData instances that need to open DB connections and load data from disk.
     This way, you only run expensive operations when really needed.
     
     */
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        try! CoreDataFeedStore(storeURL:
                                NSPersistentContainer
            .defaultDirectoryURL()
            .appendingPathComponent("feed-store.sqlite"))
    }()
    
   
    // Since iOS 14, if we don't explicitly hold a reference to the RemoteFeedLoader instance, it'll be deallocated before it completes the operation - so the feed will never load.
    // That's because the Combine publisher won't hold a reference to it anymore (it used to hold the reference in iOS 13).
    // Tests did not catch that!
    private let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
//    private lazy var remoteFeedLoader = RemoteLoader(url: remoteURL, client: httpClient, mapper: FeedItemsMapper.map)
    
    private lazy var localFeedLoader: LocalFeedLoader = {
        LocalFeedLoader(store: store, currentDate: Date.init)
    }()
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore) {
        self.init()
        self.httpClient = httpClient
        self.store = store
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        
        configureWindow()
    }
    
    func configureWindow() {
        let rootController = FeedUIComposer.feedComposedWith(feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                                                             imageLoader: makeLocalImageLoaderWithRemoteFallback)
        window?.rootViewController = UINavigationController(rootViewController: rootController)
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    // MARK: - Factories
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<[FeedImage], Error> {
        return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
        
        //  [ side-effect ]
        //  [ pure function ]
        //  [ side-effect ]
    }
    
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let remoteImageLoader = RemoteFeedImageDataLoader(client: httpClient)
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: {
                remoteImageLoader
                    .loadImageDataPublisher(from: url)
                    .caching(to: localImageLoader, using: url)
            })
    }
}
