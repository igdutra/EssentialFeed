//
//  CoreDataStore.swift
//  EssentialFeed
//
//  Created by Ivo on 09/03/23.
//

import CoreData

public final class CoreDataStore: FeedStore {
    public init() { }
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [EssentialFeed.LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}

// MARK: - Core Data Class

private class ManagedCache: NSManagedObject {
     @NSManaged var timestamp: Date
     @NSManaged var feed: NSOrderedSet
 }

 private class ManagedFeedImage: NSManagedObject {
     @NSManaged var id: UUID
     @NSManaged var imageDescription: String?
     @NSManaged var location: String?
     @NSManaged var url: URL
     @NSManaged var cache: ManagedCache
 }
