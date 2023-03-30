//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Ivo on 12/01/23.
//

import Foundation

// The API team calls it Item instead of Image
struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
