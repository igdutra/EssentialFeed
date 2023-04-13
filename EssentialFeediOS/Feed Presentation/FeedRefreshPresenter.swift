//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Ivo on 13/04/23.
//

import EssentialFeed

// MARK: - MVP ViewModels

struct FeedLoadingViewModel {
    let isLoading: Bool
}

struct FeedRefreshMVPViewModel {
    let feed: [FeedImage]
}

// MARK: - View Protocols

protocol FeedLoadingView {
    func display(_ viewModel: FeedLoadingViewModel)
 }

 protocol FeedRefreshView {
     func display(_ viewModel: FeedRefreshMVPViewModel)
 }

 final class FeedRefreshPresenter {
     typealias Observer<T> = (T) -> Void

     private let feedLoader: FeedLoader

     init(feedLoader: FeedLoader) {
         self.feedLoader = feedLoader
     }

     var feedView: FeedRefreshView?
     var loadingView: FeedLoadingView?

     func loadFeed() {
         loadingView?.display(FeedLoadingViewModel(isLoading: true))
         feedLoader.load { [weak self] result in
             if let feed = try? result.get() {
                 self?.feedView?.display(FeedRefreshMVPViewModel(feed: feed))
             }
             self?.loadingView?.display(FeedLoadingViewModel(isLoading: false))
         }
     }
 }
