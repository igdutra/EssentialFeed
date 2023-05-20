//
//  FeedItemsMapper.swift
//  Essentials-Network
//
//  Created by Ivo on 24/11/22.
//

import Foundation



// 1 - I forgt to make it internal
// HOWEVER was only in swift 5 that internal became the default so we are now removing all the internal
final class FeedItemsMapper {
    private struct Root: Decodable {
        private let items: [RemoteFeedItem]
        
        /* NOTE DTO - Data Transfer Object
         
         The API team calls it Item instead of Image
         The RemoteFeedItem was in a separate file so that the Array extension could access it.
         Use DTOs to keep code DECOUPLED from API details
         */
        private struct RemoteFeedItem: Decodable {
            let id: UUID
            let description: String?
            let location: String?
            let image: URL
        }
        
        var images: [FeedImage] {
            items.map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
        }
    }
    
    private static var OK_200: Int { return 200 }
    
    /// When Item was private:
    /// This is done in order to: the API DETAILS ARE PRIVATE, separated from the FeedLoader protocol
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [FeedImage] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.images
    }
}
