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

// MARK: - Adapter

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

private final class FeedViewAdapter: FeedRefreshView {
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
