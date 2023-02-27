import XCTest
import LOTRCharacterFeed

final class RemoteBooksLoaderTests: XCTestCase {
    
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
        let anError = anyNSError()
        
        expect(sut, toCompleteWith: .failure(RemoteBooksLoader.Error.connectivity), when: {
            client.complete(with: anError)
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPClientResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let data = anyData()
        let samples = [100, 199, 300, 399, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: data, at: index)
            })
        }
    }
    
    func test_load_deliversUnAuthorizedErrorOn400HTTPClientResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let data = anyData()
        
        expect(sut, toCompleteWith: failure(.unauthorized), when: {
            client.complete(withStatusCode: 401, data: data)
        })
    }
    
    func test_load_deliversErrorOn200HTTPClientResponseWithInvalidJSON() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let invalidData = anyData()
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: invalidData, at: 0)
        })
    }
    
    func test_load_deliversEmptyItemOn200HTTPClientResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPClientResponseWithValidJSON() {
        let (sut, client) = makeSUT()
                
        let item1 = makeItem(
            id: "5cf5805fb53e011a64671582",
            name: "a name",
            publisher: "a publisher",
            barcode: "a barcode",
            coverURL: URL(string: "http://any-url.com")!
        )
        
        let item2 = makeItem(
            id: "5cf5805fb53e011a64671582",
            name: "another name",
            publisher: "another publisher",
            barcode: "another barcode",
            coverURL: URL(string: "http://another-url.com")!
        )
        
        let items = [item1.model, item2.model]
    
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    func test_load_doseNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
        let url = anyURL()
        let client = HTTPClientSpy()
        let request = MockRequest(url: url).create()
        var sut: RemoteBooksLoader? = RemoteBooksLoader(request: request, client: client)
        
        
        var capturedResult: [RemoteBooksLoader.Result] = []
        sut?.load(completion: { capturedResult.append($0) })
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteBooksLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let request = MockRequest(url: url).create()
        let sut = RemoteBooksLoader(request: request, client: client)
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    func expect(_ sut: RemoteBooksLoader, toCompleteWith expectedResult: RemoteBooksLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
                case let (.success(expectedItems), .success(receivedItems)):
                    XCTAssertEqual(expectedItems, receivedItems, file: file, line: line)
                    
                case let (.failure(expectedError as RemoteBooksLoader.Error), .failure(receivedError as RemoteBooksLoader.Error)):
                    XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                default:
                    XCTFail("Expected to get \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeItem(id: String,
                          name: String,
                          publisher: String,
                          barcode: String,
                          coverURL: URL
    ) -> (model: BookItem, json: [String: Any]) {
        let json = [
            "_id": id,
            "name": name,
            "publisher": publisher,
            "ISBN13": barcode,
            "coverURL": coverURL.absoluteString,
        ].compactMapValues { $0 }
        
        let model = BookItem(id: id,
                             name: name,
                             publisher: publisher,
                             barcode: barcode,
                             coverURL: coverURL
        )
        
        return (model, json)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json = ["docs": items,
                    "total": 933,
                    "limit": 1000,
                    "offset": 0,
                    "page": 1,
                    "pages": 1] as [String : Any]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteBooksLoader.Error) -> RemoteBooksLoader.Result {
        return .failure(error)
    }

}
