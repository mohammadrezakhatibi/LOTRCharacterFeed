//
//  RemoteCharacterImageDataLoader.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/24/22.
//

import XCTest
import LOTRCharacterFeed

final class RemoteCharacterImageDataLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func loadImageData(completion: @escaping (Error) -> Void) {
        client.get(from: url, completion: { result in
            switch result {
                case let .failure(error):
                    completion(error)
                default:
                    break
            }
        })
    }
}

final class RemoteCharacterImageDataLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageData_deliversErrorOnHTTPClientError() {
        let anError = NSError(domain: "an error", code: 0)
        let (sut, client) = makeSUT()
        
        let exp = expectation(description: "Wait for load completion")
        var receiverError: Error?
        sut.loadImageData { error in
            receiverError = error
            exp.fulfill()
        }
        
        client.complete(with: anError)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(receiverError as NSError?, anError)
        
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCharacterImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCharacterImageDataLoader(url: url, client: client)
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var completions = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
        var requestedURLs: [URL] {
            return completions.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            completions.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            completions[index].completion(.failure(error))
        }
        
        func complete(withStatusCode status: Int, data: Data, at index: Int = 0) {
            let response = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: status,
                httpVersion: nil,
                headerFields: nil)!
            
            completions[index].completion(.success((data, response)))
        }
    }
}
