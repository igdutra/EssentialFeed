//
//  FeedRefreshViewModel.swift
//  EssentialFeediOS
//
//  Created by Ivo on 07/04/23.
//

import Foundation
import EssentialFeed

final class FeedRefreshMVVMViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func loadFeed() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                self.onFeedLoad?(feed)
            }
            self.onLoadingStateChange?(false)
        }
    }
}
