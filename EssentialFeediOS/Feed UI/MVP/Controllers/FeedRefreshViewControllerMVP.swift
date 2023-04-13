//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewControllerMVP: NSObject, FeedLoadingView {
    
    private(set) lazy var refreshView: UIRefreshControl = loadView()
    
    // Decouple Controller with the presentation Layer
    private let loadFeed: () -> Void
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    
    @objc
    func refresh() {
        loadFeed()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshView.beginRefreshing()
        } else {
            refreshView.endRefreshing()
        }
    }
    
    private func loadView()  -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
