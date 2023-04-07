//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

public enum FeedUIComposerMVC {
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewControllerMVC {
        let refreshController = FeedRefreshViewControllerMVC(feedLoader: feedLoader)
        let feedController = FeedViewControllerMVC(refreshController: refreshController)
        refreshController.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    // NOTE: Adapter
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewControllerMVC,
                                                   loader: FeedImageDataLoader) -> FeedRefreshViewControllerMVC.Result {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellControllerMVC(model: model, imageLoader: loader)
            }
        }
    }
}
