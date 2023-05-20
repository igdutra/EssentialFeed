//
//  RemoteFeedLoader.swift
//  Essentials-Network
//
//  Created by Ivo on 21/11/22.
//

import Foundation

/* NOTE FeedLoader conformance
 
 The conformance to FeedLoader protocol will now be done ONLY AT THE COMPOSITION ROOT!
 
 */
public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemsMapper.map)
    }
}
