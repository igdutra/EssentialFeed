//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import CoreData

// Note: almost same as EssentialFeed

@objc(LegacyManagedFeedImage)
class LegacyManagedFeedImage: NSManagedObject {
	@NSManaged var id: UUID
	@NSManaged var imageDescription: String?
	@NSManaged var location: String?
	@NSManaged var url: URL
	@NSManaged var data: Data?
	@NSManaged var cache: LegacyManagedCache
}

extension LegacyManagedFeedImage {
	static func first(with url: URL, in context: NSManagedObjectContext) throws -> LegacyManagedFeedImage? {
		let request = NSFetchRequest<LegacyManagedFeedImage>(entityName: entity().name!)
		request.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(LegacyManagedFeedImage.url), url])
		request.returnsObjectsAsFaults = false
		request.fetchLimit = 1
		return try context.fetch(request).first
	}

	static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
		return NSOrderedSet(array: localFeed.map { local in
			let managed = LegacyManagedFeedImage(context: context)
			managed.id = local.id
			managed.imageDescription = local.description
			managed.location = local.location
			managed.url = local.url
			return managed
		})
	}

	var local: LocalFeedImage {
		return LocalFeedImage(id: id, description: imageDescription, location: location, url: url)
	}
}
