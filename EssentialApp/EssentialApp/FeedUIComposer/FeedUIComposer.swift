//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ivo on 21/04/23.
//

import UIKit
import Combine
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposer {
    private init() { }
    
    public static func feedComposedWith(
        feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>,
        imageLoader: @escaping (URL) -> FeedImageDataLoader.Publisher
    ) -> FeedViewController {
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader)
        
        let feedController = makeFeedViewController(delegate: presentationAdapter,
                                                    title: FeedPresenter.title)
        
        let feedView = FeedViewAdapter(controller: feedController,
                                       imageLoader: { imageLoader($0).dispatchOnMainQueue() })
        let loadingView = WeakRefVirtualProxy(feedController)
        let errorView = WeakRefVirtualProxy(feedController)
        
        presentationAdapter.presenter = LoadResourcePresenter(resourceView: feedView,
                                                              loadingView: loadingView,
                                                              errorView: errorView,
                                                              mapper: FeedPresenter.map)
        
        return feedController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewController
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
