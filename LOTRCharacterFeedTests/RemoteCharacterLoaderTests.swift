//
//  RemoteCharacterLoaderTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/21/22.
//

import XCTest

protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    func get(from url: URL, completion: @escaping (Result) -> Void)
}

final class RemoteCharacterLoader {
    
    let url: URL
    let client: HTTPClient
    
    enum Error: Swift.Error {
        case invalidData
        case connectivity
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    typealias Result = Error
    func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
                case .failure:
                    completion(.connectivity)
                case .success:
                    completion(.invalidData)
            }
        }
    }
}

final class RemoteCharacterLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnHTTPClientError() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        expect(sut, toCompleteWith: .connectivity, when: {
            client.complete(with: NSError(domain: "", code: 0))
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPClientResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let data = Data()
        let samples = [100, 199, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: .invalidData, when: {
                client.complete(withStatusCode: code, data: data, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPClientResponseWithInvalidJSON() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let invalidData = Data("invalid data".utf8)
        
        expect(sut, toCompleteWith: .invalidData, when: {
            client.complete(withStatusCode: 200, data: invalidData, at: 0)
        })
    }
    
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: RemoteCharacterLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteCharacterLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    func expect(_ sut: RemoteCharacterLoader, toCompleteWith result: RemoteCharacterLoader.Result, when action: () -> Void) {
    
        var expectedResult: RemoteCharacterLoader.Result?
        sut.load { receivedError in
            expectedResult = receivedError
        }
        
        action()
        
        XCTAssertEqual(expectedResult, result)
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
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }

}
