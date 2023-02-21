import XCTest
import LOTRCharacterFeed

final class RemoteLoaderTests: XCTestCase {

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
        
        expect(sut, toCompleteWith: .failure(RemoteLoader.Error.connectivity), when: {
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
            id: "5cd99d4bde30eff6ebccfbe6",
            height: "198cm (6'6\")",
            race: "Human",
            gender: "Female",
            birth: "March 1 ,2931",
            spouse: "Arwen",
            death: "FO 120",
            realm: "Reunited Kingdom, Arnor, Gondor",
            hair: "Dark",
            name: "Aragorn II Elessar",
            wikiURL: URL(string: "http://lotr.wikia.com//wiki/Aragorn_II_Elessar")!,
            imageURL: URL(string: "http://any-image-url.com")!
        )
        
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
            wikiURL: URL(string: "http://lotr.wikia.com//wiki/Aragorn_II_Elessar")!,
            imageURL: URL(string: "http://any-image-url.com")!
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
        var sut: RemoteLoader? = RemoteLoader(request: request, client: client)
        
        
        var capturedResult: [CharacterLoader.Result] = []
        sut?.load(completion: { capturedResult.append($0) })
        
        sut = nil
        client.complete(withStatusCode: 200, data: makeItemJSON([]))
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    func test_toModel_deliverConvertedCharacterItem() {
        let model1 = RemoteCharacterItem(id: UUID().uuidString, height: "a height", race: "a race", gender: "a gender", birth: "a birth", spouse: "a spouse", death: "a death", realm: "a realm", hair: "a hair", name: "a name", wikiUrl: URL(string: "https://any-url.com")!, imageUrl: URL(string: "https://any-image-url.com")!)
        let model2 = RemoteCharacterItem(id: UUID().uuidString, height: "a height", race: "a race", gender: "a gender", birth: "a birth", spouse: "a spouse", death: "a death", realm: "a realm", hair: "a hair", name: "a name", wikiUrl: URL(string: "https://any-url.com")!, imageUrl: URL(string: "https://any-image-url.com")!)
        
        let items = [model1, model2]
        
        XCTAssertEqual(model1._id, items.toModel().first?.id)
        XCTAssertEqual(model1.height, items.toModel().first?.height)
        XCTAssertEqual(model1.race, items.toModel().first?.race)
        XCTAssertEqual(model1.gender, items.toModel().first?.gender)
        XCTAssertEqual(model1.birth, items.toModel().first?.birth)
        XCTAssertEqual(model1.spouse, items.toModel().first?.spouse)
        XCTAssertEqual(model1.death, items.toModel().first?.death)
        XCTAssertEqual(model1.realm, items.toModel().first?.realm)
        XCTAssertEqual(model1.hair, items.toModel().first?.hair)
        XCTAssertEqual(model1.name, items.toModel().first?.name)
        XCTAssertEqual(model2._id, items.toModel()[1].id)
    }
    
    // MARK: - Helpers
    
    private func makeSUT(url: URL = URL(string: "http://any-url.com")!, file: StaticString = #filePath, line: UInt = #line) -> (sut: RemoteLoader, client: HTTPClientSpy) {
        
        let client = HTTPClientSpy()
        let request = MockRequest(url: url).create()
        let sut = RemoteLoader(request: request, client: client)
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        return (sut, client)
    }
    
    func expect(_ sut: RemoteLoader, toCompleteWith expectedResult: CharacterLoader.Result, when action: () -> Void, file: StaticString = #filePath, line: UInt = #line) {
    
        let exp = expectation(description: "Wait for load completion")
        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
                case let (.success(expectedItems), .success(receivedItems)):
                    XCTAssertEqual(expectedItems, receivedItems, file: file, line: line)
                    
                case let (.failure(expectedError as RemoteLoader.Error), .failure(receivedError as RemoteLoader.Error)):
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
                          wikiURL: URL,
                          imageURL: URL) -> (model: CharacterItem, json: [String: Any]) {
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
            "wikiUrl": wikiURL.absoluteString,
            "imageUrl": imageURL.absoluteString
        ].compactMapValues { $0 }
        
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
            wikiURL: wikiURL,
            imageURL: imageURL)
        
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
    
    private func failure(_ error: RemoteLoader.Error) -> CharacterLoader.Result {
        return .failure(error)
    }

}
