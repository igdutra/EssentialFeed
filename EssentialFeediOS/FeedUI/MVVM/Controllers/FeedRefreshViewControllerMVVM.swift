//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewModel {
    typealias Observer<T> = (T) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onFeedLoad: Observer<[FeedImage]>?
    
    func load() {
        onLoadingStateChange?(true)
        feedLoader.load { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                self.onFeedLoad?(feed)
                self.onLoadingStateChange?(false)
            }
        }
    }
}

final class FeedRefreshViewControllerMVVM: NSObject {
    
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    private let viewModel: FeedRefreshViewModel
    
    init(viewModel: FeedRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    @objc
    func refresh() {
        viewModel.load()
    }
    
    private func binded(_ view: UIRefreshControl)  -> UIRefreshControl {
        viewModel.onLoadingStateChange = { [weak view] isLoading in
            if isLoading {
                view?.beginRefreshing()
            } else {
                view?.endRefreshing()
            }
        }
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
