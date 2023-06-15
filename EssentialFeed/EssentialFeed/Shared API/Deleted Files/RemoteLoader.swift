//
//  RemoteLoader.swift
//  EssentialFeed
//
//  Created by Ivo on 20/05/23.
//

import Foundation

/* NOTE how remote loader was deleted
 
 Remote Loader composition, extension RemoteLoader: FeedLoader where Resource == [FeedImage] {} in the scene delegate, was replaced by a functional way of composing dependencies
 
 Hum! But this way we loose the Connectivity Error Type.
 */

// MARK: - Conformances in the Composition Root

extension RemoteLoader: FeedLoader where Resource == [FeedImage] { }

public final class RemoteLoader<Resource> {
    private let url: URL
    private let client: HTTPClient
    private let mapper: Mapper
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = Swift.Result<Resource, Swift.Error>
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    
    public init(url: URL, client: HTTPClient, mapper: @escaping Mapper) {
        self.url = url
        self.client = client
        self.mapper = mapper
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case let .success((data, response)):
                completion(self.map(data, from: response))
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let resource = try mapper(data, response)
            return .success(resource)
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
