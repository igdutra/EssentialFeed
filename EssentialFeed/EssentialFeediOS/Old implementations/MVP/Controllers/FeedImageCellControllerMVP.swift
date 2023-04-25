//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Ivo on 06/04/23.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegateMVP {
    func didRequestImage()
    func didCancelImageRequest()
}

final class FeedImageCellControllerMVP: FeedImageViewOld {
    private let delegate: FeedImageCellControllerDelegateMVP
    private lazy var cell = FeedImageCellViewCode()
    
    init(delegate: FeedImageCellControllerDelegateMVP) {
        self.delegate = delegate
    }
    
    func view() -> UITableViewCell {
        delegate.didRequestImage()
        return cell
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
    }
    
    func display(_ viewModel: FeedImageMVPViewModel<UIImage>) {
        cell.locationContainer.isHidden = !viewModel.hasLocation
        cell.locationLabel.text = viewModel.location
        cell.descriptionLabel.text = viewModel.description
        cell.feedImageView.image = viewModel.image
        cell.feedImageContainer.isShimmeringMVVM = viewModel.isLoading
        cell.feedImageRetryButton.isHidden = !viewModel.shouldRetry
        cell.onRetry = delegate.didRequestImage
    }
}
