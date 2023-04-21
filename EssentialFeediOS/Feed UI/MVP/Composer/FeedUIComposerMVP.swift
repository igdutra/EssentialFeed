//
//  FeedUIComposerMVP.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

public enum FeedUIComposerMVP {

    public static func feedComposedWith(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewControllerMVP {
        let presentationAdapter = FeedLoaderPresentationAdapterMVP(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewControllerMVP(delegate: presentationAdapter)
        let feedController = FeedViewControllerMVP(refreshController: refreshController)
        
//        let feedView = FeedViewAdapterMVP(controller: feedController, imageLoader: imageLoader)
//        let loadingView = WeakRefVirtualProxy(refreshController)
        
        /*
         Note: to avoid fixing the errorView and adding it twice, this will be fixed later
         */
        
//        let presenter = FeedPresenter(feedView: feedView, loadingView: loadingView)
//        presentationAdapter.presenter = presenter
        
        return feedController
    }
}

// MARK: - Weak Proxy
/* Proxy was moved to separate files in the Storyboard
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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
     func display(_ model: FeedImageMVPViewModel<UIImage>) {
         object?.display(model)
     }
 }
 */
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

private final class FeedViewAdapterMVP: FeedRefreshView {
    private weak var controller: FeedViewControllerMVP?
    private let imageLoader: FeedImageDataLoader
    
    init(controller: FeedViewControllerMVP, imageLoader: FeedImageDataLoader) {
        self.controller = controller
        self.imageLoader = imageLoader
    }
    
    func display(_ viewModel: FeedRefreshMVPViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            let adapter = FeedImageDataLoaderPresentationAdapterMVP<WeakRefVirtualProxy<FeedImageCellControllerMVP>, UIImage>(model: model, imageLoader: imageLoader)
            let view = FeedImageCellControllerMVP(delegate: adapter)
            
            adapter.presenter = FeedImagePresenter(
                view: WeakRefVirtualProxy(view),
                imageTransformer: UIImage.init)
            
            return view
        }
    }
}

// MARK: - The last Adapter -> which could be an Application Service or Infrastructure Service

/* NOTE This is what makes it unidirectional
 
 The Presenter does not depend on core Logic (Feed Feature)
 
 Does the presenter is pretty lean and clean
 
 */

private final class FeedLoaderPresentationAdapterMVP: FeedRefreshViewControllerDelegateMVP {
    private let feedLoader: FeedLoader
    var presenter: FeedRefreshPresenter?
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        feedLoader.load { [weak self] result in
            switch result {
            case let .success(feed):
                self?.presenter?.didFinishLoadingFeed(with: feed)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingFeed(with: error)
            }
        }
    }
}

private final class FeedImageDataLoaderPresentationAdapterMVP<View: FeedImageView, Image>: FeedImageCellControllerDelegateMVP where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingImageData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.url) { [weak self] result in
            switch result {
            case let .success(data):
                self?.presenter?.didFinishLoadingImageData(with: data, for: model)
                
            case let .failure(error):
                self?.presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        }
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
