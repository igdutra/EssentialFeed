//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Ivo on 21/04/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapterWithoutCombine: FeedView {
    private weak var controller: FeedViewControllerBeforeImageFeature?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewControllerBeforeImageFeature, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapterWithoutCombine<WeakRefVirtualProxy<FeedImageCellControllerBeforeImageFeature>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellControllerBeforeImageFeature(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        })
    }
}
