//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import CoreData
import EssentialFeed

/* NOTE
 
 Async CoreDataFeedStore implementation of FeedStore
 
*/
extension CoreDataFeedStore: FeedStore {
	
	public func retrieve(completion: @escaping RetrievalCompletion) {
		perform { context in
			completion(Result {
				try LegacyManagedCache.find(in: context).map {
					CachedFeed(feed: $0.localFeed, timestamp: $0.timestamp)
				}
			})
		}
	}
	
	public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
		perform { context in
			completion(Result {
				let managedCache = try LegacyManagedCache.newUniqueInstance(in: context)
				managedCache.timestamp = timestamp
				managedCache.feed = LegacyManagedFeedImage.images(from: feed, in: context)
				try context.save()
			})
		}
	}
	
	public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
		perform { context in
			completion(Result {
				try LegacyManagedCache.find(in: context).map(context.delete).map(context.save)
			})
		}
	}
	
}
