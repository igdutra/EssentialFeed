//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ivo on 13/04/23.
//

import Foundation
import EssentialFeed

// MARK: - View Protocols

protocol FeedLoadingViewOld {
    func display(_ viewModel: FeedLoadingMVPViewModel)
}

protocol FeedRefreshViewOld {
    func display(_ viewModel: FeedRefreshMVPViewModel)
}

protocol FeedErrorViewOld {
    func display(_ viewModel: FeedErrorViewData)
}

final class FeedRefreshPresenter {
    
    private let feedView: FeedRefreshViewOld
    private let loadingView: FeedLoadingViewOld
    private let errorView: FeedErrorViewOld
    
    init(feedView: FeedRefreshViewOld, loadingView: FeedLoadingViewOld, errorView: FeedErrorViewOld) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    // TODO: Add LocalizableStrings protocol, based on the SwiftGen
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedRefreshPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    private var feedLoadError: String {
        return NSLocalizedString("FEED_VIEW_CONNECTION_ERROR",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedRefreshPresenter.self),
                                 comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingMVPViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedRefreshMVPViewModel(feed: feed))
        loadingView.display(FeedLoadingMVPViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingMVPViewModel(isLoading: false))
    }
}
