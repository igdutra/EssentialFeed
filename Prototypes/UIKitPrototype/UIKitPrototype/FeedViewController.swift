//
//  FeedViewController.swift
//  UIKitPrototype
//
//  Created by Ivo on 31/03/23.
//

import UIKit

final class FeedViewController: UITableViewController {
    
    private let feed = FeedImageViewModel.prototypeFeed

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feed.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedImageCell", for: indexPath) as! FeedImageCell
        let model = feed[indexPath.row]
        cell.configure(with: model)
        return cell
    }
}
