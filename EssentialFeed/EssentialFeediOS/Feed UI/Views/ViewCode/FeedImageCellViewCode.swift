//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Ivo on 05/04/23.
//

import UIKit.UITableViewCell

/* NOTE
 
 this viewCode is missing constraints
 
 */
 public final class FeedImageCellViewCode: UITableViewCell {
     public let locationContainer = UIView()
     public let locationLabel = UILabel()
     public let descriptionLabel = UILabel()
     public let feedImageContainer = UIView()
     public let feedImageView = UIImageView()
     
     private(set) public lazy var feedImageRetryButton: UIButton = {
         let button = UIButton()
         button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
         return button
     }()
     
     var onRetry: (() -> Void)?
     
     @objc private func retryButtonTapped() {
         onRetry?()
     }
     
     public override func prepareForReuse() {
         feedImageView.image = nil
     }
 }
