//
//  SceneDelegateForUITesting.swift
//  EssentialApp
//
//  Created by Ivo on 26/04/23.
//

import UIKit
import CoreData
import EssentialFeed

class SceneDelegateForUITesting: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    let localStoreURL = NSPersistentContainer
        .defaultDirectoryURL()
        .appendingPathComponent("feed-store.sqlite")
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        configureWindow()
    }
    
    func configureWindow() {
        let remoteURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let remoteClient = makeRemoteClient()
        let remoteFeedLoader = RemoteFeedLoader(url: remoteURL, client: remoteClient)
        let remoteImageLoader = RemoteFeedImageDataLoader(client: remoteClient)
        
        let localStore = try! CoreDataFeedStore(storeURL: localStoreURL)
        let localFeedLoader = LocalFeedLoader(store: localStore, currentDate: Date.init)
        let localImageLoader = LocalFeedImageDataLoader(store: localStore)
        
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
        return URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }
}

