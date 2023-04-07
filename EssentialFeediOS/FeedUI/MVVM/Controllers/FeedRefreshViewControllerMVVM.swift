//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

final class FeedRefreshViewControllerMVVM: NSObject {
    
    private(set) lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    private let viewModel: FeedRefreshViewModel
    
    init(viewModel: FeedRefreshViewModel) {
        self.viewModel = viewModel
    }
    
    @objc
    func refresh() {
        viewModel.loadFeed()
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
