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
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageView.alpha = 0
    }
    
    // MARK: - Mehtods
    
    func configure(with model: FeedImageViewModel) {
        locationLabel.text = model.location
        locationContainer.isHidden = model.location == nil
        
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
        
        fadeIn(UIImage(named: model.imageName))
    }
    
    private func fadeIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(withDuration: 0.3,
                       delay: 0.3,
                       options: [],
                       animations: { self.feedImageView.alpha = 1 })
    }
}
