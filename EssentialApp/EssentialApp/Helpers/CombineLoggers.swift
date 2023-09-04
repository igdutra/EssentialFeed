//
//  CombineLoggers.swift
//  EssentialApp
//
//  Created by Ivo on 04/09/23.
//

import os
import UIKit
import Combine

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
