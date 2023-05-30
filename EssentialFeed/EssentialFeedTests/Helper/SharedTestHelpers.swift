//
//  XCTestCase+MemoryLeakTracking.swift later refactored to only XCTestCase
//  Essentials-NetworkTests
//
//  Created by Ivo on 08/12/22.
//

import XCTest

public extension XCTestCase {
    func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file, line: line)
        }
    }
    
    // MARK: - Stubs
    
    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 1)
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
}

func makeFeedJSON(items: [[String: Any]]) -> Data {
    let feed = ["items": items]
    return try! JSONSerialization.data(withJSONObject: feed)
}

// URL had to be moved out in order to be used in uniqueItems()
func anyURL(_ host: String = "a-url.com") -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = host
    return components.url!
}

extension HTTPURLResponse {
    convenience init(statusCode: Int) {
        self.init(url: anyURL(), statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }
}
