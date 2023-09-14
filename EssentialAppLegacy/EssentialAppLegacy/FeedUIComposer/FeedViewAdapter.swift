//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Ivo on 21/04/23.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

/* NOTE Without Combine
 
 FeedViewAdapter in EssentialAppLegacy
 
 */
final class FeedViewAdapter: FeedView {
    private weak var controller: FeedViewControllerBeforeImageFeature?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewControllerBeforeImageFeature, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<FeedImageCellControllerBeforeImageFeature>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellControllerBeforeImageFeature(delegate: adapter)
            
            adapter.presenter = FeedImagePresenterBeforeImageFeature(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        })
    }
}
