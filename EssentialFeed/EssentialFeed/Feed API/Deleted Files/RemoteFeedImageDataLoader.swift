//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Ivo on 24/04/23.
//

import Foundation

/* NOTE
 HTTP Publisher + Mapper that will deal with the RemoteFeedImageDataLoader.
 
 As of the HTTPClientTaskWrapper, THIS WILL BE HANDLED BY THE HTTPCLIENT GET PUBLISHER
 ` .handleEvents(receiveCancel: { task?.cancel() })`
 
 No functionality was lost! With amazing less code!
 */
public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    public func loadImageData(from url: URL) throws -> Data { Data() } // New API
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        var wrapped: HTTPClientTask?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in Error.connectivity }
                .flatMap { (data, response) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(Error.invalidData)
                })
            
        }
        return task
    }
}
