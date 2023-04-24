//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Ivo on 24/04/23.
//

import Foundation

public protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}
