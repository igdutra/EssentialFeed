//
//  PresenterViews.swift
//  EssentialFeed
//
//  Created by Ivo on 22/06/23.
//

import Foundation

// MARK: - Resource

public protocol ResourceView {
    associatedtype ResourceViewModel
    
    func display(_ viewModel: ResourceViewModel)
}

// MARK: - Loading

public protocol ResourceLoadingView {
    func display(_ viewModel: ResourceLoadingViewModel)
}

public struct ResourceLoadingViewModel {
    public let isLoading: Bool
}

// MARK: - Error
