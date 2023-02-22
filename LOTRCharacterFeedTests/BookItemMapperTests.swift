import XCTest
import LOTRCharacterFeed

final class BookItemMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPClientResponse() throws {
        let data = anyData()
        let samples = [100, 199, 300, 399, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try BookItemMapper.map(data, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
            )
        }
    }
    
    func test_map_throwsUnAuthorizedErrorOn400HTTPClientResponse() throws {
        let data = anyData()

        XCTAssertThrowsError(
            try BookItemMapper.map(data, response: HTTPURLResponse(url: anyURL(), statusCode: 401, httpVersion: nil, headerFields: nil)!)
        )
    }
    
    func test_map_throwsOn200HTTPClientResponseWithInvalidJSON() {
        let invalidData = anyData()
        
        XCTAssertThrowsError(
            try BookItemMapper.map(invalidData, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        )
    }
    
    func test_map_deliversEmptyItemOn200HTTPClientResponseWithEmptyJSON() throws {
        let emptyListJSON = makeItemJSON([])
        
        let items = try BookItemMapper.map(emptyListJSON, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        XCTAssertEqual(items, [])
    }
    
    func test_map_deliversItemsOn200HTTPClientResponseWithValidJSON() throws {
        let item1 = makeItem(
            id: "5cf58080b53e011a64671584",
            name: "The Return Of The King",
            publisher: "William Morrow",
            ISBN13: "978-435455515",
            coverURL: URL(string: "http://image-url.com")!
        )
        
        let item2 = makeItem(
            id: "5cf5805fb53e011a64671582",
            name: "The Fellowship Of The Ring",
            publisher: "William Morrow",
            ISBN13: "978-0618260515",
            coverURL: URL(string: "http://another-image-url.com")!
        )
        
        let items = [item1.model, item2.model]
        let json = makeItemJSON([item1.json, item2.json])
        
        let output = try BookItemMapper.map(json, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        XCTAssertEqual(output, items)
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: String,
                          name: String,
                          publisher: String,
                          ISBN13: String,
                          coverURL: URL) -> (model: BookItem, json: [String: Any]) {
        let json = [
            "_id": id,
            "name": name,
            "publisher": publisher,
            "ISBN13": ISBN13,
            "coverURL": coverURL.absoluteString
        ].compactMapValues { $0 }
        
        let model = BookItem(
            id: id,
            name: name,
            publisher: publisher,
            ISBN13: ISBN13,
            coverURL: coverURL)
        
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
