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
        var items: [RemoteCharacterItem]
        
        struct RemoteCharacterItem: Codable {
            var _id: String
            var height: String
            var race: String
            var gender: String
            var birth: String
            var spouse: String
            var death: String
            var realm: String
            var hair: String
            var name: String
            var wikiUrl: String
        
            init(id: String, height: String, race: String, gender: String, birth: String, spouse: String, death: String, realm: String, hair: String, name: String, wikiUrl: String) {
                self._id = id
                self.height = height
                self.race = race
                self.gender = gender
                self.birth = birth
                self.spouse = spouse
                self.death = death
                self.realm = realm
                self.hair = hair
                self.name = name
                self.wikiUrl = wikiUrl
            }
        }
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
                    
                    completion(.success(root.items.map {
                        CharacterItem(id: $0._id, height: $0.height, race: $0.race, gender: $0.gender, birth: $0.birth, spouse: $0.spouse, death: $0.death, realm: $0.realm, hair: $0.hair, name: $0.name, wikiURL: URL(string: $0.wikiUrl)!)
                    }))
                    
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
        
        expect(sut, toCompleteWith: .success([]), when: {
            let emptyListJSON = makeItemJSON([])
            client.complete(withStatusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversItemsOn200HTTPClientResponseWithValidJSON() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem(
            id: "5cd99d4bde30eff6ebccfbe6",
            height: "198cm (6'6\")",
            race: "Human",
            gender: "Male",
            birth: "March 1 ,2931",
            spouse: "Arwen",
            death: "FO 120",
            realm: "Reunited Kingdom, Arnor, Gondor",
            hair: "Dark",
            name: "Aragorn II Elessar",
            wikiURL: "http://lotr.wikia.com//wiki/Aragorn_II_Elessar")
        
        
        let item2 = makeItem(
            id: "5cd99d4bde3ewef6ebccfbe6",
            height: "208cm (6'6\")",
            race: "Elves",
            gender: "Male",
            birth: "March 1 ,931",
            spouse: "Narbia",
            death: "Departed to Aman in FO 120 from Ithilien",
            realm: "Reunited Kingdom, Arnor, Gondor",
            hair: "Golden",
            name: "Legolas",
            wikiURL: "http://lotr.wikia.com//wiki/Aragorn_II_Elessar")
        
        let items = [item1.model, item2.model]
    
        expect(sut, toCompleteWith: .success(items), when: {
            let json = makeItemJSON([item1.json, item2.json])
            client.complete(withStatusCode: 200, data: json)
        })
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteCharacterLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let sut = RemoteCharacterLoader(url: url, client: client)
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
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
    
    private func makeItem(id: String,
                          height: String,
                          race: String,
                          gender: String,
                          birth: String,
                          spouse: String,
                          death: String,
                          realm: String,
                          hair: String,
                          name: String,
                          wikiURL: String) -> (model: CharacterItem, json: [String: Any]) {
        let json = [
            "_id": id,
            "height": height,
            "race": race,
            "gender": gender,
            "birth": birth,
            "spouse": spouse,
            "death": death,
            "realm": realm,
            "hair": hair,
            "name": name,
            "wikiUrl": wikiURL
        ]
        
        let model = CharacterItem(
            id: id,
            height: height,
            race: race,
            gender: gender,
            birth: birth,
            spouse: spouse,
            death: death,
            realm: realm,
            hair: hair,
            name: name,
            wikiURL: URL(string: wikiURL)!)
        
        return (model, json)
    }
    
    private func makeItemJSON(_ items: [[String: Any]]) -> Data {
        let json = ["items": items]
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    private func failure(_ error: RemoteCharacterLoader.Error) -> RemoteCharacterLoader.Result {
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

    private func trackingForMemoryLeaks(_ instance: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak on \(String(describing: instance))", file: file, line: line)
        }
    }
}
