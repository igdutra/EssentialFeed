//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import CoreData

// Note: almost same as EssentialFeed

@objc(LegacyManagedCache)
class LegacyManagedCache: NSManagedObject {
	@NSManaged var timestamp: Date
	@NSManaged var feed: NSOrderedSet
}

extension LegacyManagedCache {
	static func find(in context: NSManagedObjectContext) throws -> LegacyManagedCache? {
		let request = NSFetchRequest<LegacyManagedCache>(entityName: entity().name!)
		request.returnsObjectsAsFaults = false
		return try context.fetch(request).first
	}
	
	static func newUniqueInstance(in context: NSManagedObjectContext) throws -> LegacyManagedCache {
		try find(in: context).map(context.delete)
		return LegacyManagedCache(context: context)
	}
	
	var localFeed: [LocalFeedImage] {
		return feed.compactMap { ($0 as? LegacyManagedFeedImage)?.local }
	}
}
