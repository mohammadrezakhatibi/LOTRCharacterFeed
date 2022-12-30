//
//  RemoteCharacterImageDataLoader.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/24/22.
//

import XCTest
import LOTRCharacterFeed

final class RemoteCharacterImageDataLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let (_, client, _) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_loadImageDataFromURL_requestsDataFromURL() {
        let url = anyURL()
        let (sut, client, request) = makeSUT()
        
        _ = sut.loadImageData(request: request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_loadImageDataFromURLTwice_requestsDataFromURLTwice() {
        let url = anyURL()
        let (sut, client, request) = makeSUT()
        
        _ = sut.loadImageData(request: request) { _ in }
        _ = sut.loadImageData(request: request) { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_loadImageDataFromURL_deliversErrorOnHTTPClientError() {
        let (sut, client, _) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.connectivity), when: {
            client.complete(with: anyNSError())
        })
    }
        
    func test_loadImageDataFromURL_deliversErrorOnNon200HTTPClientResponse() {
        let (sut, client, _) = makeSUT()
        let samples = [100, 199, 300, 400, 500]
        
        samples.enumerated().forEach { (index, code) in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: Data(), at: index)
            })
        }
    }
    
    func test_loadImageDataFromURL_delviresInvalidDataErrorOn200HTTPResponseWithEmptyData() {
        let (sut, client, _) = makeSUT()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: Data())
        })
    }
    
    func test_loadImageDataFromURL_deliverReceivedNonEmptyDataOn200HTTPResponse() {
        let (sut, client, _) = makeSUT()
        let nonEmptyData = anyData()
        
        expect(sut, toCompleteWith: .success(nonEmptyData), when: {
            client.complete(withStatusCode: 200, data: nonEmptyData)
        })
    }
    
    func test_cancelLoadImageDataFromURLTask_cancelsClientURLRequest() {
        let givenURL = URL(string: "https://a-given-url.com")!
        let (sut, client, request) = makeSUT(url: givenURL)
        
        let task = sut.loadImageData(request: request) { _ in }
        XCTAssertTrue(client.canceledURLs.isEmpty, "Expected no canceled URL request until task is cancelled")
        
        task.cancel()
        XCTAssertEqual(client.canceledURLs, [givenURL], "Expected canceled URL request after task is cancelled")
    }
    
    func test_loadImageDataFromURL_doseNotDeliverResultAfterCancellingTask() {
        let givenURL = URL(string: "https://a-given-url.com")!
        let (sut, client, request) = makeSUT(url: givenURL)
        
        var receivedResult = [CharacterImageDataLoader.Result]()
        let task = sut.loadImageData(request: request) { receivedResult.append($0) }
        
        task.cancel()
        
        client.complete(withStatusCode: 200, data: anyData())
        client.complete(withStatusCode: 400, data: anyData())
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty, "Expecting empty result, but got \(receivedResult)")
    }
    
    func test_loadImageDataFromURL_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let givenURL = URL(string: "https://a-given-url.com")!
        let client = HTTPClientSpy()
        let request = MockRequest(url: givenURL)
        var sut: RemoteCharacterImageDataLoader? = RemoteCharacterImageDataLoader(client: client)
        
        var receivedResult = [CharacterImageDataLoader.Result]()
        _ = sut?.loadImageData(request: request) { receivedResult.append($0) }
        
        sut = nil
        
        client.complete(withStatusCode: 200, data: anyData())
        client.complete(withStatusCode: 400, data: anyData())
        client.complete(with: anyNSError())
        
        XCTAssertTrue(receivedResult.isEmpty, "Expecting empty result, but got \(receivedResult)")
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = anyURL(),file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCharacterImageDataLoader, client: HTTPClientSpy, request: Request) {
        let client = HTTPClientSpy()
        let sut = RemoteCharacterImageDataLoader(client: client)
        let request = MockRequest(url: url)
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        return (sut, client, request)
    }
    
    private func expect(_ sut: RemoteCharacterImageDataLoader, toCompleteWith expectedResult: CharacterImageDataLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
        let request = MockRequest(url: anyURL())
        let exp = expectation(description: "Wait for load completion")
        _ = sut.loadImageData(request: request) { receivedResult in
            switch (receivedResult, expectedResult) {
                case let (.failure(receiverError), .failure(expectedError)):
                    XCTAssertEqual(receiverError as? RemoteCharacterImageDataLoader.Error, expectedError as? RemoteCharacterImageDataLoader.Error, file: file, line: line)
                    
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
    
    private func failure(_ error: RemoteCharacterImageDataLoader.Error) -> CharacterImageDataLoader.Result {
        return .failure(error)
    }
    
    private class MockRequest: Request {
        
        init(url: URL) {
            self.url = url
        }
        
        var url: URL
        
        var body: Data? = nil
        
        var header: [String : String]? = nil
        
    }
}
