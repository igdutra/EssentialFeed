//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Ivo on 21/04/23.
//

import Foundation

// MARK: - View Protocols

public protocol FeedView {
    func display(_ viewModel: FeedViewModel)
}

// Note: Replaced by ResourceLoadingViewModel
//public protocol FeedLoadingView {
//    func display(_ viewModel: FeedLoadingViewModel)
//}

// Note: Replaced by ResourceErrorView
//public protocol FeedErrorView {
//    func display(_ viewModel: FeedErrorViewModel)
//}

// MARK: - Presenter

public final class FeedPresenter {
    private let feedView: FeedView
    private let loadingView: ResourceLoadingView
    private let errorView: ResourceErrorView
    
    // NOTE use LocalizedStrings protocol
    public static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    public static var feedLoadError: String {
        return NSLocalizedString("GENERIC_CONNECTION_ERROR",
                                 tableName: "Shared",
                                 bundle: Bundle(for: FeedPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public init(feedView: FeedView, loadingView: ResourceLoadingView, errorView: ResourceErrorView) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }    
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(ResourceLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: Self.feedLoadError))
        loadingView.display(ResourceLoadingViewModel(isLoading: false))
    }
}
