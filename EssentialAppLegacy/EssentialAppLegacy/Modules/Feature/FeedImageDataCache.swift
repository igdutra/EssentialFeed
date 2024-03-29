//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

/* NOTE
 
 Async implementation of FeedImageDataCache
 
*/
public protocol FeedImageDataCache {
	typealias Result = Swift.Result<Void, Error>

	func save(_ data: Data, for url: URL, completion: @escaping (Result) -> Void)
}
