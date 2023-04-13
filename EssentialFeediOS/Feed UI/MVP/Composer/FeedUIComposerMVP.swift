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
        let presenter = FeedRefreshPresenter()
        let presentationAdapter = FeedLoaderPresentationAdapter(feedLoader: feedLoader, presenter: presenter)
        let refreshController = FeedRefreshViewControllerMVP(loadFeed: presentationAdapter.loadFeed)
        let feedController = FeedViewControllerMVP(refreshController: refreshController)
        
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, imageLoader: imageLoader)
        
        return feedController
    }
}

// MARK: - Weak Proxy

private final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingView where T: FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
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
    private weak var controller: FeedViewControllerMVP?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewControllerMVP, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedRefreshMVPViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellControllerMVP(viewModel:
                                        FeedImageViewModelPresenter(model: model, imageLoader: imageLoader, imageTransformer: UIImage.init))
        }
    }
}

// MARK: - The last Adapter -> which could be an Application Service or Infrastructure Service

/* NOTE This is what makes it unidirectional
 
 The Presenter does not depend on core Logic (Feed Feature)
 
 Does the presenter is pretty lean and clean
 
 */

private final class FeedLoaderPresentationAdapter {
    private let feedLoader: FeedLoader
    private let presenter: FeedRefreshPresenter
    
    init(feedLoader: FeedLoader, presenter: FeedRefreshPresenter) {
        self.feedLoader = feedLoader
        self.presenter = presenter
    }
    
    func loadFeed() {
        presenter.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter.didFinishLoadingFeed(with: error)
            }
        }
    }
}
