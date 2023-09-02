//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Ivo on 31/07/23.
//

import Foundation

public enum FeedEndpoint {
    case get
    
    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v1/feed"
            components.queryItems = [
                URLQueryItem(name: "limit", value: "10")
            ]
            // Note:
            // Decided to force-unwrap because if no valid base-url is provided, is developer error and there are unit tests to back it up
            return components.url!
        }
    }
}
