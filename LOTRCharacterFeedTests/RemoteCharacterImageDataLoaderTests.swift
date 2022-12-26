//
//  RemoteCharacterImageDataLoader.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/24/22.
//

import XCTest
import LOTRCharacterFeed

protocol CharacterImageDataLoaderTask {
    func cancel()
}
final class RemoteCharacterImageDataLoader {
    
    let url: URL
    let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    private struct HTTPClientTaskWrapper: CharacterImageDataLoaderTask {
        var task: HTTPClientTask?
        
        func cancel() {
            task?.cancel()
        }
    }
    
    typealias Result = Swift.Result<(Data), Error>
    
    @discardableResult
    func loadImageData(completion: @escaping (RemoteCharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
        var task = HTTPClientTaskWrapper()
        task.task = client.get(from: url, completion: { result in
            completion(result
                .mapError { _ in
                    Error.connectivity
                }
                .flatMap{ data, response in
                    if response.statusCode == 200, !data.isEmpty {
                        return .success(data)
                    } else {
                        return .failure(.invalidData)
                    }
                }
            )
        })
        
        return task
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
    
    func test_loadImageDataTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.loadImageData { _ in }
        sut.loadImageData { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageData_deliversErrorOnHTTPClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }
        
    func test_loadImageData_deliversErrorOnNon200HTTPClientResponse() {
        let (sut, client) = makeSUT()
        let samples = [100, 199, 300, 400, 500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: Data(), at: index)
            })
        }
    }
    
    func test_loadImageData_delviresInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: Data())
        })
    }
    
    func test_loadImageData_deliverReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()
        
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_cancelLoadImageDataURLTask_cancelsClientURLRequest() {
        let givenURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: givenURL)
        
        let task = sut.loadImageData { _ in }
        XCTAssertTrue(client.canceledURLs.isEmpty, "Expected no canceled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.canceledURLs, [givenURL], "Expected canceled URL request after task is cancelled")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://a-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCharacterImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCharacterImageDataLoader(url: url, client: client)
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteCharacterImageDataLoader, toCompleteWith expectedResult: RemoteCharacterImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        sut.loadImageData { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.failure(receiverError), .failure(expectedError)):
                    XCTAssertEqual(receiverError, expectedError, file: file, line: line)
                    
                case let (.success(receiverData), .success(expectedData)):
                    XCTAssertEqual(receiverData, expectedData, file: file, line: line)
                    
                default:
                    XCTFail("Expecting \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func failure(_ error: RemoteCharacterImageDataLoader.Error) -> RemoteCharacterImageDataLoader.Result {
        return .failure(error)
    }
}
