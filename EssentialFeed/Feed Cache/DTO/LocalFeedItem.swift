//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Ivo on 12/01/23.
//

import Foundation

// Why RemoteFeedITem is internal, while LocalFeedItem is public?
public struct LocalFeedItem: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}
