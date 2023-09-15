//
//  Copyright © 2018 Essential Developer. All rights reserved.
//

import Foundation
import EssentialFeed

/* NOTE
 - using same HTTPClient and URLSessionHTTPClient
 
RemoteFeedLoader was replaced by Shared RemoteLoader<Resource>
 
extension RemoteLoader: FeedLoader where Resource == [FeedImage] { }

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
 convenience init(url: URL, client: HTTPClient) {
     self.init(url: url, client: client, mapper: FeedItemsMapper.map)
 }
}
 
And then later on replaced by Combine
*/
public final class RemoteFeedLoader: FeedLoader {
	private let url: URL
	private let client: HTTPClient
	
	public enum Error: Swift.Error {
		case connectivity
		case invalidData
	}
	
	public typealias Result = FeedLoader.Result
	
	public init(url: URL, client: HTTPClient) {
		self.url = url
		self.client = client
	}
	
	public func load(completion: @escaping (Result) -> Void) {
		client.get(from: url) { [weak self] result in
			guard self != nil else { return }
			
			switch result {
			case let .success((data, response)):
				completion(RemoteFeedLoader.map(data, from: response))
				
			case .failure:
				completion(.failure(Error.connectivity))
			}
		}
	}
	
	private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
		do {
			let items = try FeedItemsMapper.map(data, from: response)
			return .success(items.toModels())
		} catch {
			return .failure(error)
		}
	}
}

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}

private extension Array where Element == RemoteFeedItem {
	func toModels() -> [FeedImage] {
		return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.image) }
	}
}
