//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Ivo on 12/01/23.
//

import Foundation

// Why RemoteFeedITem is internal, while LocalFeedItem is public?
public struct LocalFeedImage: Equatable, Codable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String?, location: String?, url: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = url
    }
}
