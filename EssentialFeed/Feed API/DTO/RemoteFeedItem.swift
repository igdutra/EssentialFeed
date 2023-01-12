//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Ivo on 12/01/23.
//

import Foundation

// The API team calls it Item instead of Image
internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
