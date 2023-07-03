//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ivo on 21/04/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

public final class FeedUIComposerWithoutCombine {
    private init() { }
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewControllerBeforeImageFeature {
        let presentationAdapter = FeedLoaderPresentationAdapterWithoutCombine(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        
        let feedController = makeFeedViewController(delegate: presentationAdapter,
                                                    title: FeedPresenter.title)
        
        let feedView = FeedViewAdapterWithoutCombine(controller: feedController,
                                       imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        let loadingView = WeakRefVirtualProxy(feedController)
        let errorView = WeakRefVirtualProxy(feedController)

        presentationAdapter.presenter = FeedPresenter(feedView: feedView,
                                                      loadingView: loadingView,
                                                      errorView: errorView)
        
        return feedController
    }

    private static func makeFeedViewController(delegate: FeedViewControllerBeforeImageFeatureDelegate, title: String) -> FeedViewControllerBeforeImageFeature {
        let bundle = Bundle(for: FeedViewControllerBeforeImageFeature.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewControllerBeforeImageFeature
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
