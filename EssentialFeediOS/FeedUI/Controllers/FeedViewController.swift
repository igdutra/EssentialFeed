//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 03/04/23.
//

import EssentialFeed
import UIKit

public final class FeedViewController: UITableViewController {
    
    var tableModel = [FeedImageCellController]() {
        didSet { tableView.reloadData() }
    }
    private var refreshController: FeedRefreshViewController?
    private var cellControllers = [IndexPath: FeedImageCellController]()
    
    convenience init(refreshController: FeedRefreshViewController) {
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
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellController {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension FeedViewController: UITableViewDataSourcePrefetching {
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
