//
//  LocalFeedLoader.swift
//  Persistence-Essentials
//
//  Created by Ivo on 10/01/23.
//

import Foundation
import Network

public final class LocalFeedLoader {
    private let store: FeedStore
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    public typealias LoadResult = LoadFeedResult
    
    public init(store: FeedStore, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
    public func save(_ images: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed { [weak self] error in
            guard let self = self else { return }
            
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(images, with: completion)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve {  [unowned self] result in
            switch result {
            case let .failure(error):
                completion(.failure(error))
           
            case let .found(feed, timestamp) where self.validate(timestamp):
                completion(.success(feed.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
    
    // MARK: - Helpers
    
    private func cache(_ images: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(images.toLocal(), timestamp: currentDate()) { [weak self] error in
             guard self != nil else { return }

             completion(error)
         }
     }
    
    private func validate(_ timestamp: Date) -> Bool {
         let calendar = Calendar(identifier: .gregorian)
         guard let maxCacheAge = calendar.date(byAdding: .day, value: 7, to: timestamp) else {
             return false
         }
         return currentDate() < maxCacheAge
     }
}

private extension Array where Element == FeedImage {
     func toLocal() -> [LocalFeedImage] {
         return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
     }
 }

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}
