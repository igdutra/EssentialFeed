//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Ivo on 03/07/23.
//

import Foundation

public final class FeedImagePresenter {
    public static func map(_ image: FeedImage) -> FeedImageViewModel {
        FeedImageViewModel(
            description: image.description,
            location: image.location)
    }
}
