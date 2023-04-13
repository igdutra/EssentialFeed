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
protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewControllerStoryboard: NSObject, FeedLoadingView {
    
    @IBOutlet private var refreshView: UIRefreshControl?
    
    // Decouple Controller with the presentation Layer
    var delegate: FeedRefreshViewControllerDelegate?
    
    /* NOTE Init
     
     Init removed since we cannot use constructor injection no longer
     
     */
    
    @IBAction
    func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            refreshView?.beginRefreshing()
        } else {
            refreshView?.endRefreshing()
        }
    }
    
    private func loadView()  -> UIRefreshControl {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return view
    }
}
