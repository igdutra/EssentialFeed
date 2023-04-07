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
        let viewModel = FeedRefreshViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewControllerMVVM(viewModel: viewModel)
        let feedController = FeedViewControllerMVVM(refreshController: refreshController)
        viewModel.onRefresh = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    // NOTE: Adapter
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewControllerMVVM,
                                                   loader: FeedImageDataLoader) -> FeedRefreshViewModel.Result {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellControllerMVVM(model: model, imageLoader: loader)
            }
        }
    }
}
