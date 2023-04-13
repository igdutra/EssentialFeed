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
