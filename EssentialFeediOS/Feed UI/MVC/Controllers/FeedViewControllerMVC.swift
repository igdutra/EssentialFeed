//
//  FeedViewController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 03/04/23.
//

import EssentialFeed
import UIKit

public final class FeedViewControllerMVC: UITableViewController {
    
    var tableModel = [FeedImageCellControllerMVC]() {
        didSet { tableView.reloadData() }
    }
    private var refreshController: FeedRefreshViewControllerMVC?
    private var cellControllers = [IndexPath: FeedImageCellControllerMVC]()
    
    convenience init(refreshController: FeedRefreshViewControllerMVC) {
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
    
    /* NOTE Possible iOS 15+ bug
     
     If some of the images are not rendering, is because when scrolling and comming back, the cell will not be called using cellForRowAt, it will simply reuse the element and call willDisplay
     So the task should be re-started
     
     */
    
    private func cellController(forRowAt indexPath: IndexPath) -> FeedImageCellControllerMVC {
        return tableModel[indexPath.row]
    }
    
    private func cancelCellControllerLoad(forRowAt indexPath: IndexPath) {
        cellController(forRowAt: indexPath).cancelLoad()
    }
}

// MARK: - UITableViewDataSourcePrefetching
extension FeedViewControllerMVC: UITableViewDataSourcePrefetching {
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
