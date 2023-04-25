//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Ivo on 14/04/23.
//

import UIKit

final class WeakRefVirtualProxyStoryboard<T: AnyObject> {
    private weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxyStoryboard: FeedLoadingViewOld where T: FeedLoadingViewOld {
    func display(_ viewModel: FeedLoadingMVPViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxyStoryboard: FeedImageViewOld where T: FeedImageViewOld, T.Image == UIImage {
    func display(_ model: FeedImageMVPViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxyStoryboard: FeedErrorViewOld where T: FeedErrorViewOld {
    func display(_ viewModel: FeedErrorViewData) {
        object?.display(viewModel)
    }
}
