//
//  FeedImageViewModel.swift
//  EssentialFeed
//
//  Created by Ivo on 03/07/23.
//

import Foundation

public struct FeedImageViewModel {
     public let description: String?
     public let location: String?

     public var hasLocation: Bool {
         return location != nil
    }
}
