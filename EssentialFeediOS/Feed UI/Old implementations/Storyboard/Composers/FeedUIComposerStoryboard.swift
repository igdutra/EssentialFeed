//
//  FeedUIComposerMVP.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

public enum FeedUIComposerStoryboard {

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewControllerStoryboard {
        let presentationAdapter = FeedLoaderPresentationAdapterStoryboard(feedLoader: MainQueueDispatchDecoratorStoryboard(decoratee: feedLoader))
        
        let feedController = makeFeedViewController(delegate: presentationAdapter,
                                                    title: FeedRefreshPresenter.title)
        
        let feedView = FeedViewAdapterStoryboard(controller: feedController,
                                       imageLoader: MainQueueDispatchDecoratorStoryboard(decoratee: imageLoader))
        let loadingView = WeakRefVirtualProxyStoryboard(feedController)
        let errorView = WeakRefVirtualProxyStoryboard(feedController)
        let presenter = FeedRefreshPresenter(feedView: feedView, loadingView: loadingView, errorView: errorView)
        
        presentationAdapter.presenter = presenter
        
        return feedController
    }

    static func makeFeedViewController(delegate: FeedViewControllerDelegate,
                                       title: String) -> FeedViewControllerStoryboard {
        let bundle = Bundle(for: FeedViewControllerStoryboard.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewControllerStoryboard
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
