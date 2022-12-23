//
//  RemoteCharacterLoaderTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/21/22.
//

import XCTest
import LOTRCharacterFeed

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
    
    private struct Root: Codable {
        var items: [CharacterItem]
    }
    
    typealias Result = CharacterLoader.Result
    
    func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { result in
            switch result {
                case .failure:
                    completion(.failure(RemoteCharacterLoader.Error.connectivity))
                case let .success((data, response)):
                    guard response.statusCode == 200, let root = try? JSONDecoder().decode(Root.self, from: data) else {
                        
                        return completion(.failure(RemoteCharacterLoader.Error.invalidData))
                    }
                    
                    completion(.success(root.items))
                    
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
        
        expect(sut, toCompleteWith: .failure(RemoteCharacterLoader.Error.connectivity), when: {
            client.complete(with: NSError(domain: "", code: 0))
        })
    }
    
    func test_load_deliversErrorOnNon200HTTPClientResponse() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let data = Data()
        let samples = [100, 199, 300, 400, 500]
        
        samples.enumerated().forEach { index, code in
            expect(sut, toCompleteWith: failure(.invalidData), when: {
                client.complete(withStatusCode: code, data: data, at: index)
            })
        }
    }
    
    func test_load_deliversErrorOn200HTTPClientResponseWithInvalidJSON() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        let invalidData = Data("invalid data".utf8)
        
        expect(sut, toCompleteWith: failure(.invalidData), when: {
            client.complete(withStatusCode: 200, data: invalidData, at: 0)
        })
    }
    
    func test_load_deliversEmptyItemOn200HTTPClientResponseWithEmptyJSON() {
        let (sut, client) = makeSUT()
        let emptyJSON = ["items": []]
        let data = try! JSONSerialization.data(withJSONObject: emptyJSON)
        
        expect(sut, toCompleteWith: .success([]), when: {
            client.complete(withStatusCode: 200, data: data)
        })
    }
    
    func test_load_deliversItemsOn200HTTPClientResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        let item = [
            "_id": "5cd99d4bde30eff6ebccfbe6",
            "height": "198cm (6'6\")",
            "race": "Human",
            "gender": "Male",
            "birth": "March 1 ,2931",
            "spouse": "Arwen",
            "death": "FO 120",
            "realm": "Reunited Kingdom,Arnor,Gondor",
            "hair": "Dark",
            "name": "Aragorn II Elessar",
            "wikiUrl": "http://lotr.wikia.com//wiki/Aragorn_II_Elessar"
        ]
        
        let json = [
            "items": [item]
        ]
        
        let items = CharacterItem(
            _id: "5cd99d4bde30eff6ebccfbe6",
            height: "198cm (6'6\")",
            race: "Human",
            gender: "Male",
            birth: "March 1 ,2931",
            spouse: "Arwen",
            death: "FO 120",
            realm: "Reunited Kingdom,Arnor,Gondor",
            hair: "Dark",
            name: "Aragorn II Elessar",
            wikiUrl: "http://lotr.wikia.com//wiki/Aragorn_II_Elessar")
        
        let data = try! JSONSerialization.data(withJSONObject: json)
        
        expect(sut, toCompleteWith: .success([items]), when: {
            client.complete(withStatusCode: 200, data: data)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!) -> (sut: RemoteCharacterLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteCharacterLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    func expect(_ sut: RemoteCharacterLoader, toCompleteWith expectedResult: RemoteCharacterLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
                case let (.success(expectedItems), .success(receivedItems)):
                    XCTAssertEqual(expectedItems, receivedItems, file: file, line: line)
                    
                case let (.failure(expectedError as RemoteCharacterLoader.Error), .failure(receivedError as RemoteCharacterLoader.Error)):
                    XCTAssertEqual(expectedError, receivedError, file: file, line: line)
                default:
                    XCTFail("Expected to get \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func failure(_ error: RemoteCharacterLoader.Error) -> RemoteCharacterLoader.Result {
        return .failure(error)
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
