//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

/* NOTE
 
 FeedLoader protocol was deleted since now the only UseCase that was implementing it was the LocalFeedLoader
 
 Since there's only one implementation, there's no need for a Strategy Pattern anymore, so that's why it got deleted.
 
 */
public protocol FeedLoader {
	typealias Result = Swift.Result<[FeedImage], Error>
	
	func load(completion: @escaping (Result) -> Void)
}
