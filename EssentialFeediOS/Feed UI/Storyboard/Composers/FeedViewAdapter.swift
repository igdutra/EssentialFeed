//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Ivo on 14/04/23.
//

import UIKit
import EssentialFeed

// MARK:  Adapter

/* NOTE Adapter into object
 
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
 
 */

final class FeedViewAdapter: FeedRefreshView {
    private weak var controller: FeedViewControllerStoryboard?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewControllerStoryboard, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedRefreshMVPViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellControllerStoryboard>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellControllerStoryboard(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        }
    }
}
