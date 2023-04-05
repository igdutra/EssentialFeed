//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Ivo on 05/04/23.
//

import UIKit.UITableViewCell

 public final class FeedImageCell: UITableViewCell {
     public let locationContainer = UIView()
     public let locationLabel = UILabel()
     public let descriptionLabel = UILabel()
     public let feedImageContainer = UIView()
     public let feedImageView = UIImageView()
     public let feedImageRetryButton = UIButton()
     
     public override func prepareForReuse() {
         feedImageView.image = nil
     }
 }
