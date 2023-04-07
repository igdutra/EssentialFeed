//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewModel {
    public typealias Result = ([FeedImage]) -> Void
    
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onRefresh: Result?
    var isLoading: Bool = false
    
    func load() {
        isLoading = true
        feedLoader.load { [weak self] result in
            guard let self else { return }
            if let feed = try? result.get() {
                self.onRefresh?(feed)
                self.isLoading = false
            }
        }
    }
}


final class FeedRefreshViewControllerMVVM: NSObject {
    
    private(set) lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        bind(view)
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }()
    
    private let viewModel: FeedRefreshViewModel
    
    init(viewModel: FeedRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    @objc
    func refresh() {
        viewModel.load()
    }
    
    private func bind(_ view: UIRefreshControl) {
        if viewModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
