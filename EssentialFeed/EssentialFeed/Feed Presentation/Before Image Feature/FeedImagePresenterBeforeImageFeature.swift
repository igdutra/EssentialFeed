//
//  FeedImagePresenter.swift
//  EssentialFeed
//
//  Created by Ivo on 21/04/23.
//

public protocol FeedImageView {
    associatedtype Image
    
    func display(_ model: FeedImageViewModelBeforeImageFeature<Image>)
}

// NOTE:
// FeedImagePresenter was replaced only by its mapping function, but since it uses generics this one was kept for conformance reasons
public final class FeedImagePresenterBeforeImageFeature<View: FeedImageView, Image> where View.Image == Image {
    
    public static func map(_ image: FeedImage) -> FeedImageViewModelBeforeImageFeature<Image> {
        FeedImageViewModelBeforeImageFeature(
             description: image.description,
             location: image.location,
             image: nil,
             isLoading: false,
             shouldRetry: false)
     }
    
    private let view: View
    private let imageTransformer: (Data) -> Image?
    
    public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    public func didStartLoadingImageData(for model: FeedImage) {
        view.display(FeedImageViewModelBeforeImageFeature(description: model.description,
                                        location: model.location,
                                        image: nil,
                                        isLoading: true,
                                        shouldRetry: false))
    }
    
    public func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        let image = imageTransformer(data)
        view.display(FeedImageViewModelBeforeImageFeature(description: model.description,
                                        location: model.location,
                                        image: image,
                                        isLoading: false,
                                        shouldRetry: image == nil))
    }
    
    public func didFinishLoadingImageData(with error: Error, for model: FeedImage) {
        view.display(FeedImageViewModelBeforeImageFeature(description: model.description,
                                        location: model.location,
                                        image: nil,
                                        isLoading: false,
                                        shouldRetry: true))
    }
}
