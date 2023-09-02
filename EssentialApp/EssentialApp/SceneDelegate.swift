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
    private let baseURL = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed")!
//    private lazy var remoteFeedLoader = RemoteLoader(url: remoteURL, client: httpClient, mapper: FeedItemsMapper.map)
    
    private lazy var navigationController = UINavigationController(rootViewController:
        FeedUIComposer.feedComposedWith(feedLoader: makeRemoteFeedLoaderWithLocalFallback,
                                        imageLoader: makeLocalImageLoaderWithRemoteFallback,
                                        selection: showComments)
    )
    
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
        window?.rootViewController = navigationController
        
        window?.makeKeyAndVisible()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache { _ in }
    }
    
    // TODO: use the ImageCommentsFlow created in the challenge
    // Note: it is safe to append image.id because it is an UUID, only uses URL valid characters.
    private func showComments(for image: FeedImage) {
        let url = ImageCommentsEndpoint.get(image.id).url(baseURL: baseURL)
        let comments = CommentsUIComposer.commentsComposedWith(commentsLoader: makeRemoteCommentsLoader(url: url))
        navigationController.pushViewController(comments, animated: true)
    }
    
    // Note: helper function that's why return a closure that returns
    private func makeRemoteCommentsLoader(url: URL) -> () -> AnyPublisher<[ImageComment], Error> {
        return { [httpClient] in
            return httpClient
                .getPublisher(url: url)
                .tryMap(ImageCommentsMapper.map)
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: - Factories
    
    private func makeRemoteFeedLoaderWithLocalFallback() -> AnyPublisher<Paginated<FeedImage>, Error> {
        let remoteURL = FeedEndpoint.get().url(baseURL: baseURL)
        return httpClient
            .getPublisher(url: remoteURL)
            .tryMap(FeedItemsMapper.map)
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map { items in
                Paginated(items: items, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: items, last: items.last))
            }
            .eraseToAnyPublisher()
        
        //  [ side-effect ]
        //  [ pure function ]
        //  [ side-effect ]
    }
    
    private func makeRemoteLoadMoreLoader(items: [FeedImage], last: FeedImage?)
    -> (() -> AnyPublisher<Paginated<FeedImage>, Error>)? {
        last.map { lastItem in
            let url = FeedEndpoint.get(after: lastItem).url(baseURL: baseURL)
            
            return { [httpClient, localFeedLoader] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedItemsMapper.map)
                    .map { newItems in
                        let allItems = items + newItems
                        // Recursion
                        return Paginated(items: allItems, loadMorePublisher: self.makeRemoteLoadMoreLoader(items: allItems, last: newItems.last))
                    }
                    .caching(to: localFeedLoader)
            }
        }
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .fallback(to: { [httpClient] in
                httpClient
                    .getPublisher(url: url)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
            })
    }
}
