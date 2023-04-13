//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 03/04/23.
//

import UIKit

// NOTE: The Controller has no need to do a viewModel
/*
 The FeedViewControllerdoesn’t communicate with any EssentialFeed core component.
 As you can see, none of its responsibilities is about managing core model state.
 That’s why, at this point, we decided it doesn’t need a View Model.
 */
public final class FeedViewControllerMVP: UITableViewController {
    
    var tableModel = [FeedImageCellControllerMVP]() {
        didSet { tableView.reloadData() }
    }
    private var refreshController: FeedRefreshViewControllerMVP?
    private var cellControllers = [IndexPath: FeedImageCellControllerMVP]()
    
    convenience init(refreshController: FeedRefreshViewControllerMVP) {
        self.init()
        self.refreshController = refreshController
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.prefetchDataSource = self
        refreshControl = refreshController?.view
        refreshController?.refresh()
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
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellControllerMVP {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FeedViewControllerMVP: UITableViewDataSourcePrefetching {
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
