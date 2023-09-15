//
//  Copyright © 2019 Essential Developer. All rights reserved.
//

import Foundation

/* NOTE
 
 Async implementation of FeedImageDataLoader
 
*/
public protocol FeedImageDataLoaderTask {
	func cancel()
}

public protocol FeedImageDataLoader {
	typealias Result = Swift.Result<Data, Error>
	
	func loadImageData(from url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}
