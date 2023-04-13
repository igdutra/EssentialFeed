//
//  FeedUIComposerMVP.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

public enum FeedUIComposerMVP {
    
    typealias FeedLoadCompletion = ([FeedImage]) -> Void
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewControllerMVP {
        let viewModel = FeedRefreshViewModelPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewControllerMVP(viewModel: viewModel)
        let feedController = FeedViewControllerMVP(refreshController: refreshController)
        viewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    // NOTE: Adapter
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewControllerMVP,
                                                   loader: FeedImageDataLoader) -> FeedLoadCompletion {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellControllerMVP(viewModel:
                                     FeedImageViewModelPresenter(model: model,
                                                        imageLoader: loader,
                                                        imageTransformer: UIImage.init))
            }
        }
    }
}
