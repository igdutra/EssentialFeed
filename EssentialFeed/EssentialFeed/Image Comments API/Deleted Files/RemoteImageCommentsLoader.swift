//
//  RemoteImageCommentsLoader.swift
//  EssentialFeed
//
//  Created by Ivo on 18/05/23.
//

import Foundation


/* NOTE
 
 RemoteImageCommentsLoader is now Generic, all the Image Commnets API needs is: RemoteLoader<[ImageComment]>
 No conformance to protocol is desired.
 
*/
public final class RemoteImageCommentsLoader {
    private let url: URL
    private let client: HTTPClient

    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }

    public typealias Result = Swift.Result<[ImageComment], Swift.Error>

    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }

    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }

            switch result {
            case let .success((data, response)):
                completion(RemoteImageCommentsLoader.map(data, from: response))

            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }

    private static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
        do {
            let items = try ImageCommentsMapper.map(data, from: response)
            return .success(items)
        } catch {
            return .failure(error)
        }
    }
}
