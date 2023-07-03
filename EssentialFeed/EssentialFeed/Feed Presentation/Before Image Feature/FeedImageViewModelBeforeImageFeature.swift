//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Ivo on 21/04/23.
//

// NOTE:
// The FeedImageViewModel combines Image details (description / location) with loading state (isLoading, retry)
// So this model needs to be broken apart in oder to be reused!
public struct FeedImageViewModelBeforeImageFeature<Image> {
    public let description: String?
    public let location: String?
    public let image: Image?
    public let isLoading: Bool
    public let shouldRetry: Bool
    
    public var hasLocation: Bool {
        return location != nil
    }
}
