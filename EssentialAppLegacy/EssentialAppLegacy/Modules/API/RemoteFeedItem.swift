//
//  RemoteFeedItem.swift
//  EssentialAppLegacy
//
//  Created by Ivo on 14/09/23.
//

import Foundation

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
