//
//  FeedImageMVPViewModel.swift
//  EssentialFeediOS
//
//  Created by Ivo on 07/04/23.
//

import Foundation
import EssentialFeed

struct FeedImageMVPViewModel<Image> {
    let description: String?
    let location: String?
    let image: Image?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}
