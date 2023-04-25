//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Ivo on 14/04/23.
//

import EssentialFeed

// MARK: - The last Adapter -> which could be an Application Service or Infrastructure Service

/* NOTE This is what makes it unidirectional
 
 The Presenter does not depend on core Logic (Feed Feature)
 
 Does the presenter is pretty lean and clean
 
 */

final class FeedLoaderPresentationAdapterStoryboard: FeedViewControllerDelegateStoryboad {
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
