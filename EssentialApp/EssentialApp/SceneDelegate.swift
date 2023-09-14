//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Ivo on 25/04/23.
//

import os
import UIKit
import CoreData
import Combine
import EssentialFeed

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    private lazy var scheduler: AnyDispatchQueueScheduler = DispatchQueue(label: "com.essentialdeveloper.infra.queue",
                                                                          qos: .userInitiated,
                                                                          attributes: .concurrent)
                                                                          .eraseToAnyScheduler()
    
    private lazy var logger = Logger(subsystem: "com.essentialdeveloper.EssentialAppCaseStudy", category: "main")
    
    /* NOTE Lazy instantiation
     
     If they are not set, we have a chance of instantiating them lazyly
     
     So lazy vars is our recommended way of creating expensive dependencies like CoreData instances that need to open DB connections and load data from disk.
     This way, you only run expensive operations when really needed.
     
     */
    private lazy var httpClient: HTTPClient = {
        URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
    }()
    
    private lazy var store: FeedStore & FeedImageDataStore = {
        do {
            return try CoreDataFeedStore(
                storeURL: NSPersistentContainer
                    .defaultDirectoryURL()
                    .appendingPathComponent("feed-store.sqlite"))
        } catch {
            assertionFailure("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            logger.fault("Failed to instantiate CoreData store with error: \(error.localizedDescription)")
            return NullStore()
        }
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
    
    convenience init(httpClient: HTTPClient, store: FeedStore & FeedImageDataStore, scheduler: AnyDispatchQueueScheduler) {
        self.init()
        self.httpClient = httpClient
        self.store = store
        self.scheduler = scheduler
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
        //        localFeedLoader.validateCache { _ in }
        do {
            try localFeedLoader.validateCache()
        } catch {
            logger.error("Failed to validate cache with error: \(error.localizedDescription)")
        }
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
        makeRemoteFeedLoader()
            .caching(to: localFeedLoader)
            .fallback(to: localFeedLoader.loadPublisher)
            .map(makeFirstPage)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteLoadMoreLoader(last: FeedImage?) -> AnyPublisher<Paginated<FeedImage>, Error> {
        localFeedLoader.loadPublisher()
            .zip(makeRemoteFeedLoader(after: last)) // Load from cash only when needed
            .map { (cachedItems, newItems) in
                (cachedItems + newItems, newItems.last)
            }
            // Mock Behavior
            // .delay(for: 2, scheduler: DispatchQueue .main)
            // .flatMap { _ in
            //    Fail(error: NSError())
            // }
            .map(makePage)
            .caching(to: localFeedLoader)
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
    
    private func makeRemoteFeedLoader(after: FeedImage? = nil) -> AnyPublisher<[FeedImage], Error> {
        let url = FeedEndpoint.get(after: after).url(baseURL: baseURL)
        
        return httpClient
            .getPublisher(url: url)
            .tryMap(FeedItemsMapper.map)
            .eraseToAnyPublisher()
        
        //  [ side-effect ]
        //  [ pure function ]
        //  [ side-effect ]
    }
    
    private func makeFirstPage(items: [FeedImage]) -> Paginated<FeedImage> {
        makePage(items: items, last: items.last)
    }
    
    private func makePage(items: [FeedImage], last: FeedImage?) -> Paginated<FeedImage> {
        Paginated(items: items, loadMorePublisher: last.map { last in
            { self.makeRemoteLoadMoreLoader(last: last) }
        })
    }
    
    private func makeLocalImageLoaderWithRemoteFallback(url: URL) -> FeedImageDataLoader.Publisher {
        let localImageLoader = LocalFeedImageDataLoader(store: store)
        
        return localImageLoader
            .loadImageDataPublisher(from: url)
            .logCacheMisses(url: url, logger: logger)
            .fallback(to: { [httpClient, scheduler] in // [logger]
                httpClient
                    .getPublisher(url: url)
                    //.logError(url: url, logger: logger)
                    //.logElapsedTime(url: url, logger: logger)
                    .tryMap(FeedImageDataMapper.map)
                    .caching(to: localImageLoader, using: url)
                    .subscribe(on: scheduler)
                    .eraseToAnyPublisher()
            })
            .subscribe(on: scheduler)
            .eraseToAnyPublisher()
    }
}
