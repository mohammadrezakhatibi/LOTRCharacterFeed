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
    
    func loadImageData() {
        client.get(from: url, completion: { _ in })
    }
}

final class RemoteCharacterImageDataLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = anyURL()
        let client = HTTPClientSpy()
        let _ = RemoteCharacterImageDataLoader(url: url, client: client)
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageData_requestsDataFromURL() {
        let url = anyURL()
        let client = HTTPClientSpy()
        let sut = RemoteCharacterImageDataLoader(url: url, client: client)
        
        sut.loadImageData()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    // MARK: - Helpers
    
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
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}
