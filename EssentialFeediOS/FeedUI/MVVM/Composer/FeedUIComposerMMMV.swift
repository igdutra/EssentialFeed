//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

public enum FeedUIComposerMVVM {
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewControllerMVVM {
        let refreshController = FeedRefreshViewControllerMVVM(feedLoader: feedLoader)
        let feedController = FeedViewControllerMVVM(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    // NOTE: Adapter
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewControllerMVVM,
                                                   loader: FeedImageDataLoader) -> FeedRefreshViewControllerMVVM.Result {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellControllerMVVM(model: model, imageLoader: loader)
            }
        }
    }
}
