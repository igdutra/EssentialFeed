//
//  FeedImageCell.swift
//  UIKitPrototype
//
//  Created by Ivo on 31/03/23.
//

import UIKit.UITableViewCell

final class FeedImageCell: UITableViewCell {
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descriptionLabel: UILabel!
}
