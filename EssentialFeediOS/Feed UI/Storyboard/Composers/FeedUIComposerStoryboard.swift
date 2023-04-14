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
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: MainQueueDispatchDecorator(decoratee: feedLoader))
        
        let feedController = FeedViewControllerStoryboard.makeWith(delegate: presentationAdapter,
                                                                    title: FeedRefreshPresenter.title)
        
        let feedView = FeedViewAdapter(controller: feedController,
                                       imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader))
        let loadingView = WeakRefVirtualProxy(feedController)
        let presenter = FeedRefreshPresenter(feedView: feedView, loadingView: loadingView)
        
        presentationAdapter.presenter = presenter
        
        return feedController
    }
}

// MARK: - Feed Controller Factory

private extension FeedViewControllerStoryboard {
    static func makeWith(delegate: FeedViewControllerDelegate, title: String) -> FeedViewControllerStoryboard {
        let bundle = Bundle(for: FeedViewControllerStoryboard.self)
        let storyboard = UIStoryboard(name: "Feed", bundle: bundle)
        let feedController = storyboard.instantiateInitialViewController() as! FeedViewControllerStoryboard
        feedController.delegate = delegate
        feedController.title = title
        return feedController
    }
}
