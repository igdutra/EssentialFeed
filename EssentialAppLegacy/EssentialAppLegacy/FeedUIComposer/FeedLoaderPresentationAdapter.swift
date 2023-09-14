//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Ivo on 21/04/23.
//

import EssentialFeed
import EssentialFeediOS

/* NOTE Without Combine
 
 FeedLoaderPresentationAdapter in EssentialAppLegacy
 
 */
final class FeedLoaderPresentationAdapter: FeedViewControllerBeforeImageFeatureDelegate {
    private let feedLoader: FeedLoader
    var presenter: FeedPresenter?
    
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
