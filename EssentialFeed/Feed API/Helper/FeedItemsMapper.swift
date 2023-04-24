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
        let items: [RemoteFeedItem]
    }
    
    private static var OK_200: Int { return 200 }
    
    /// When Item was private:
    /// This is done in order to: the API DETAILS ARE PRIVATE, separated from the FeedLoader protocol
    
    static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
