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

private final class MainQueueDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async(execute: completion)
        }
        
        completion()
    }
}

extension MainQueueDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainQueueDispatchDecorator: FeedImageDataLoader where T == FeedImageDataLoader {
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
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

extension WeakRefVirtualProxy: FeedImageView where T: FeedImageView, T.Image == UIImage {
     func display(_ model: FeedImageMVPViewModel<UIImage>) {
         object?.display(model)
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

// MARK: - The last Adapter -> which could be an Application Service or Infrastructure Service

/* NOTE This is what makes it unidirectional
 
 The Presenter does not depend on core Logic (Feed Feature)
 
 Does the presenter is pretty lean and clean
 
 */

private final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
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

private final class FeedImageDataLoaderPresentationAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
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
