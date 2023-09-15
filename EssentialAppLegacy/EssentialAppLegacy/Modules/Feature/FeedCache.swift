//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

/* NOTE
 
 Async implementation of FeedCache
 
*/
public protocol FeedCache {
	typealias Result = Swift.Result<Void, Error>

	func save(_ feed: [FeedImage], completion: @escaping (Result) -> Void)
}
