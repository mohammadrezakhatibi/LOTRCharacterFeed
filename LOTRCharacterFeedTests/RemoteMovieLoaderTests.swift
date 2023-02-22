import XCTest
import LOTRCharacterFeed

final class RemoteMovieLoaderTests: XCTestCase {

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
        
        expect(sut, toCompleteWith: .failure(RemoteMovieLoader.Error.connectivity), when: {
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
            id: "5cd95395de30eff6ebccde58",
            name: "The Unexpected Journey",
            runtime: 1.0,
            budget: 1.0,
            revenue: 1.0,
            academyAwardNominations: 1,
            academyAwardWins: 1,
            score: 1,
            posterURL: URL(string: "http://any-url.com")!
        )
        
        let item2 = makeItem(
            id: "5cd95395de30eff6ebccde56",
            name: "The Lord of the Rings Series",
            runtime: 2.0,
            budget: 2.0,
            revenue: 2.0,
            academyAwardNominations: 2,
            academyAwardWins: 2,
            score: 2,
            posterURL: URL(string: "http://any-url.com")!
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
        var sut: RemoteMovieLoader? = RemoteMovieLoader(request: request, client: client)
        
        
        var capturedResult: [RemoteMovieLoader.Result] = []
        sut?.load(completion: { capturedResult.append($0) })
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteMovieLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let request = MockRequest(url: url).create()
        let sut = RemoteMovieLoader(request: request, client: client)
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    func expect(_ sut: RemoteMovieLoader, toCompleteWith expectedResult: RemoteMovieLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
                case let (.success(expectedItems), .success(receivedItems)):
                    XCTAssertEqual(expectedItems, receivedItems, file: file, line: line)
                    
                case let (.failure(expectedError as RemoteMovieLoader.Error), .failure(receivedError as RemoteMovieLoader.Error)):
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
                          runtime: Double,
                          budget: Double,
                          revenue: Double,
                          academyAwardNominations: Int,
                          academyAwardWins: Int,
                          score: Double,
                          posterURL: URL
    ) -> (model: MovieItem, json: [String: Any]) {
        let json = [
            "_id": id,
            "name": name,
            "runtimeInMinutes": runtime,
            "budgetInMillions": budget,
            "boxOfficeRevenueInMillions": revenue,
            "academyAwardNominations": academyAwardNominations,
            "academyAwardWins": academyAwardWins,
            "rottenTomatoesScore": score,
            "posterURL": posterURL.absoluteString,
        ].compactMapValues { $0 }
        
        let model = MovieItem(
            id: id,
            name: name,
            runtime: runtime,
            budget: budget,
            revenue: revenue,
            academyAwardNominations: academyAwardNominations,
            academyAwardWins: academyAwardWins,
            score: score,
            posterURL: posterURL)
        
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
    
    private func failure(_ error: RemoteMovieLoader.Error) -> RemoteMovieLoader.Result {
        return .failure(error)
    }
}
