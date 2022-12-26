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
    
    let client: HTTPClient
    
    enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    private final class HTTPClientTaskWrapper: CharacterImageDataLoaderTask {
        private var completion: ((RemoteCharacterImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (RemoteCharacterImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: RemoteCharacterImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    typealias Result = Swift.Result<(Data), Error>
    
    @discardableResult
    func loadImageData(url: URL, completion: @escaping (RemoteCharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
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
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(url: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT()
        
        sut.loadImageData(url: url) { _ in }
        sut.loadImageData(url: url) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnHTTPClientError() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }
        
    func test_loadImageDataFromURL_deliversErrorOnNon200HTTPClientResponse() {
        let (sut, client) = makeSUT()
        let samples = [100, 199, 300, 400, 500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: Data(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_delviresInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: Data())
        })
    }
    
    func test_loadImageDataFromURL_deliverReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client) = makeSUT()
        let nonEmptyData = anyData()
        
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_cancelLoadImageDataFromURLTask_cancelsClientURLRequest() {
        let givenURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()
        
        let task = sut.loadImageData(url: givenURL) { _ in }
        XCTAssertTrue(client.canceledURLs.isEmpty, "Expected no canceled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.canceledURLs, [givenURL], "Expected canceled URL request after task is cancelled")
    }
    
    func test_loadImageDataFromURL_doseNotDeliverResultAfterCancellingTask() {
        let givenURL = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT()
        
        var receivedResult = [RemoteCharacterImageDataLoader.Result]()
        let task = sut.loadImageData(url: givenURL) { receivedResult.append($0) }
        
        task.cancel()
        
        client.complete(withStatusCode: 200, data: anyData())
        client.complete(withStatusCode: 400, data: anyData())
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty, "Expecting empty result, but got \(receivedResult)")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCharacterImageDataLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteCharacterImageDataLoader(client: client)
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    private func expect(_ sut: RemoteCharacterImageDataLoader, toCompleteWith expectedResult: RemoteCharacterImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load completion")
        sut.loadImageData(url: anyURL()) { receivedResult in
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
