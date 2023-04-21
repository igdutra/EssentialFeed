//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

// TODO: Think of a more direct name to it, looking at the diagram
/* NOTE Delegate
 
 This Delegate lives inside the Feed UI
 
 */
protocol FeedRefreshViewControllerDelegateMVP {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewControllerMVP: NSObject, FeedLoadingViewOld {
    
    private(set) lazy var refreshView: UIRefreshControl = loadView()
    
    // Decouple Controller with the presentation Layer
    private let delegate: FeedRefreshViewControllerDelegateMVP
    
    init(delegate: FeedRefreshViewControllerDelegateMVP) {
        self.delegate = delegate
    }
    
    @objc
    func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingMVPViewModel) {
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
