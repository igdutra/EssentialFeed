//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

public enum FeedUIComposerMVVM {
    
    typealias FeedLoadCompletion = ([FeedImage]) -> Void
    
    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewControllerMVVM {
        let viewModel = FeedRefreshMVVMViewModel(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewControllerMVVM(viewModel: viewModel)
        let feedController = FeedViewControllerMVVM(refreshController: refreshController)
        viewModel.onFeedLoad = adaptFeedToCellControllers(forwardingTo: feedController, loader: imageLoader)
        return feedController
    }
    
    // NOTE: Adapter
    private static func adaptFeedToCellControllers(forwardingTo controller: FeedViewControllerMVVM,
                                                   loader: FeedImageDataLoader) -> FeedLoadCompletion {
        return { [weak controller] feed in
            controller?.tableModel = feed.map { model in
                FeedImageCellControllerMVVM(viewModel:
                                     FeedImageMVVMViewModel(model: model,
                                                        imageLoader: loader,
                                                        imageTransformer: UIImage.init))
            }
        }
    }
}
