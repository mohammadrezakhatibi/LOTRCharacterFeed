import XCTest
import LOTRCharacterFeed

final class CharacterItemMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPClientResponse() throws {
        let data = anyData()
        let samples = [100, 199, 300, 399, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try CharacterItemMapper.map(data, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
            )
        }
    }
    
    func test_map_throwsUnAuthorizedErrorOn400HTTPClientResponse() throws {
        let data = anyData()

        XCTAssertThrowsError(
            try CharacterItemMapper.map(data, response: HTTPURLResponse(url: anyURL(), statusCode: 401, httpVersion: nil, headerFields: nil)!)
        )
    }
    
    func test_map_throwsOn200HTTPClientResponseWithInvalidJSON() {
        let invalidData = anyData()
        
        XCTAssertThrowsError(
            try CharacterItemMapper.map(invalidData, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        )
    }
    
    func test_map_deliversEmptyItemOn200HTTPClientResponseWithEmptyJSON() throws {
        let emptyListJSON = makeItemJSON([])
        
        let items = try CharacterItemMapper.map(emptyListJSON, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        XCTAssertEqual(items, [])
    }
    
    func test_map_deliversItemsOn200HTTPClientResponseWithValidJSON() throws {
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
        let json = makeItemJSON([item1.json, item2.json])
        
        let output = try CharacterItemMapper.map(json, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        XCTAssertEqual(output, items)
    }
    
    // MARK: - Helpers
    
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
}
