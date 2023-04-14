//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ivo on 13/04/23.
//

import EssentialFeed

// MARK: - View Protocols

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
 }

 protocol FeedRefreshView {
     func display(_ viewModel: FeedRefreshMVPViewModel)
 }

final class FeedRefreshPresenter {
    
    private let feedView: FeedRefreshView
    private let loadingView: FeedLoadingView
    
    init(feedView: FeedRefreshView, loadingView: FeedLoadingView) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    static var title: String {
        return NSLocalizedString("FEED_VIEW_TITLE",
                                 tableName: "Feed",
                                 bundle: Bundle(for: FeedRefreshPresenter.self),
                                 comment: "Title for the feed view")
    }
    
    func didStartLoadingFeed() {
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoadingFeed(with feed: [FeedImage]) {
        feedView.display(FeedRefreshMVPViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoadingFeed(with error: Error) {
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
