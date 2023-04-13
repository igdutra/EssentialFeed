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
    
    private let presenter: FeedPresenter
    
    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    @objc
    func refresh() {
        presenter.loadFeed()
    }
    
    func display(isLoading: Bool) {
        if isLoading {
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
