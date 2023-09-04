//
//  HTTPClientProfilingDecorator.swift
//  EssentialApp
//
//  Created by Ivo on 04/09/23.
//

import os
import Foundation
import EssentialFeed
import UIKit
import Combine

/*
 Note: this class was deleted since it was unsed only to verify the performance form the network layer.
 Or instead of an decorator you can inject this behavior into the publisher chain directly using Combine and Handle Events

*/
final class HTTPClientProfilingDecorator: HTTPClient {
    private let decoratee: HTTPClient
    private let logger: Logger
    
    init(decoratee: HTTPClient, logger: Logger) {
        self.decoratee = decoratee
        self.logger = logger
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        logger.trace("Started loading url: \(url.relativePath)")
        let startTime = CACurrentMediaTime()
        
        return decoratee.get(from: url) { [logger] result in
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finished loading url: \(url.relativePath, align: .left(columns:20)) in \(elapsed, format: .fixed(precision: 2)) seconds")
            print(FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!)
            completion(result)
        }
    }
}

extension Publisher {
    func logError(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        return handleEvents(receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url: \(url) with error: \(error.localizedDescription)")
            }
        }).eraseToAnyPublisher()
    }
    
    func logElapsedTime(url: URL, logger: Logger) -> AnyPublisher<Output, Failure> {
        var startTime = CACurrentMediaTime ( )
        
        return handleEvents(receiveSubscription: { _ in
            logger.trace("Started loading url: \(url)")
            startTime = CACurrentMediaTime ( )
        }, receiveCompletion: { result in
            if case let .failure(error) = result {
                logger.trace("Failed to load url: \(url) with error: \(error.localizedDescription)")
            }
            
            let elapsed = CACurrentMediaTime() - startTime
            logger.trace("Finished loading url: \(url) in \(elapsed) seconds")
        }).eraseToAnyPublisher()
    }
}
