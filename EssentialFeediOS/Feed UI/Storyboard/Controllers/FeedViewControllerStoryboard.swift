//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 03/04/23.
//

import UIKit

// It is no longer FeedRefreshViewControllerDelegate
protocol FeedViewControllerDelegate {
    func didRequestFeedRefresh()
}

// NOTE: The Controller has no need to do a viewModel
/*
 The FeedViewControllerdoesn’t communicate with any EssentialFeed core component.
 As you can see, none of its responsibilities is about managing core model state.
 That’s why, at this point, we decided it doesn’t need a View Model.
 */
public final class FeedViewControllerStoryboard: UITableViewController, FeedLoadingView {
    
    var delegate: FeedViewControllerDelegate?
    
    var tableModel = [FeedImageCellControllerStoryboard]() {
        didSet { tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refresh()
    }
    
    @IBAction private func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(_ viewModel: FeedLoadingViewModel) {
        if viewModel.isLoading {
            // UITableViewController reference to refreshControl
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView,
                                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(forRowAt: indexPath).view()
    }
    
    public override func tableView(_ tableView: UITableView,
                                   didEndDisplaying cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
        cancelCellControllerLoad(forRowAt: indexPath)
    }
    
    public override func tableView(_ tableView: UITableView,
                                   willDisplay cell: UITableViewCell,
                                   forRowAt indexPath: IndexPath) {
        // Empty
    }
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellControllerStoryboard {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewControllerStoryboard: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            cellController(forRowAt: indexPath).preload()
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        // NOTE: Benefit of writing forEach
        indexPaths.forEach(cancelCellControllerLoad)
    }
}
