//
//  URLSessionHTTPClientTests.swift
//  Essentials-NetworkTests
//
//  Created by Ivo on 08/12/22.
//

import XCTest
import EssentialFeed

final class URLSessionHTTPClientTests: XCTestCase {
    
    override func tearDown() {
        URLProtocolStub.removeStub()
        super.tearDown()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let anyURL = anyURL()
        let sut = makeSUT()
        
        let exp = expectation(description: "Wait for request")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, anyURL)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        sut.get(from: anyURL) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    /* NOTE old cancelTask test and refactor with taskHanlder
     
     func test_cancelGetFromURLTask_cancelsURLRequest() {
     let url = anyURL()
     let exp = expectation(description: "Wait for request")
     
     let task = makeSUT().get(from: url) { result in
     switch result {
     case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
     break
     
     default:
     XCTFail("Expected cancelled result, got \(result) instead")
     }
     exp.fulfill()
     }
     
     task.cancel()
     wait(for: [exp], timeout: 1.0)
     }
     
     */
    /* NOTE
     
     explanation and fix for a potential test leak in the URLSessionHTTPClientTests related to canceling URLRequests
     Wait for URLProtocol to complete the URLRequest after a task has been…
     … canceled to avoid a test leak where the URLProtocol would be start the request after the test finishes.
     This happens because cancelling a URLSessionDataTask won't immediately cancel the URLProtocol from receiving that request.
     So if we don't wait for it, there's a chance the URLProtocol request will run while another test is running and influence its result.
     
     */
    func test_cancelGetFromURLTask_cancelsURLRequest() {
         let exp = expectation(description: "Wait for request")
         URLProtocolStub.observeRequests { _ in exp.fulfill() }

         let receivedError = resultErrorFor(taskHandler: { $0.cancel() }) as NSError?
         wait(for: [exp], timeout: 1.0)

         XCTAssertEqual(receivedError?.code, URLError.cancelled.rawValue)
     }
    
    func test_getFromURL_failsOnRequestError() {
        let requestError = anyNSError()
        
        let receivedError = resultErrorFor((data: nil, response: nil, error: requestError)) as NSError?
        
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getFromURL_failsOnAllInvalidRepresentationCases() {
        XCTAssertNotNil(resultErrorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nil, error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(resultErrorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData() {
        let data = anyData()
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor((data: data, response: response, error: nil))
        
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // This was made out of a validation of the framework, and it demostrated how the framework was replacing the nil Data with a actually valid Empty representation from Data
    // And this is a valid scenario, 304, etc.
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
        let response = anyHTTPURLResponse()
        
        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))
        
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: configuration)
        
        let sut = URLSessionHTTPClient(session: session)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
        let result = resultFor(values, file: file, line: line)
        
        switch result {
        case let .success((data, response)):
            return (data, response)
        default:
            XCTFail("Expected success, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    // Note
    // The new task Handler is being used only at the cancel method.
    private func resultErrorFor(_ values: (data: Data?, response: URLResponse?, error: Error?)? = nil, taskHandler: (HTTPClientTask) -> Void = { _ in }, file: StaticString = #file, line: UInt = #line) -> Error? {
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case let .failure(error):
            return error
        default:
            XCTFail("Expected failure, got \(result) instead", file: file, line: line)
            return nil
        }
    }
    
    private func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: (HTTPClientTask) -> Void = { _ in },  file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let sut = makeSUT(file: file, line: line)
        let exp = expectation(description: "Wait for completion")
        
        var receivedResult: HTTPClient.Result!
        taskHandler(sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
        return receivedResult
    }
    
    private func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    // MARK: Helpers
    
    /*
     So First there was only one helper, resultErrorFor
     then there was the resultValues for
     
     then saw the duplication code between the helpers, and then refactored it to use just one thing.
     */
}
