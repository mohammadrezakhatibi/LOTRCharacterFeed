import XCTest
import LOTRCharacterFeed

final class MovieItemMapperTests: XCTestCase {
    
    func test_map_throwsErrorOnNon200HTTPClientResponse() throws {
        let data = anyData()
        let samples = [100, 199, 300, 399, 400, 500]
        
        try samples.forEach { code in
            XCTAssertThrowsError(
                try MovieItemMapper.map(data, response: HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!)
            )
        }
    }
    
    func test_map_throwsUnAuthorizedErrorOn400HTTPClientResponse() throws {
        let data = anyData()

        XCTAssertThrowsError(
            try MovieItemMapper.map(data, response: HTTPURLResponse(url: anyURL(), statusCode: 401, httpVersion: nil, headerFields: nil)!)
        )
    }
    
    func test_map_throwsOn200HTTPClientResponseWithInvalidJSON() {
        let invalidData = anyData()
        
        XCTAssertThrowsError(
            try MovieItemMapper.map(invalidData, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        )
    }
    
    func test_map_deliversEmptyItemOn200HTTPClientResponseWithEmptyJSON() throws {
        let emptyListJSON = makeItemJSON([])
        
        let items = try MovieItemMapper.map(emptyListJSON, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        XCTAssertEqual(items, [])
    }
    
    func test_map_deliversItemsOn200HTTPClientResponseWithValidJSON() throws {
        let item1 = makeItem(
            id: "5cd95395de30eff6ebccde56",
            name: "The Lord of the Rings Series",
            runtimeInMinutes: 1,
            budgetInMillions: 1,
            boxOfficeRevenueInMillions: 1,
            academyAwardNominations: 1,
            academyAwardWins: 1,
            rottenTomatoesScore: 1,
            posterURL: URL(string: "http://any-image-url.com")!
        )
        
        let item2 = makeItem(
            id: "5cd95395de30eff6ebccde58",
            name: "The Unexpected Journey",
            runtimeInMinutes: 2.0,
            budgetInMillions: 2.0,
            boxOfficeRevenueInMillions: 2.0,
            academyAwardNominations: 2.0,
            academyAwardWins: 2.0,
            rottenTomatoesScore: 2.0,
            posterURL: URL(string: "http://another-image-url.com")!
        )
        
        let items = [item1.model, item2.model]
        let json = makeItemJSON([item1.json, item2.json])
        
        let output = try MovieItemMapper.map(json, response: HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!)
        XCTAssertEqual(output, items)
    }
    
    // MARK: - Helpers
    
    private func makeItem(id: String,
                          name: String,
                          runtimeInMinutes: Double,
                          budgetInMillions: Double,
                          boxOfficeRevenueInMillions: Double,
                          academyAwardNominations: Double,
                          academyAwardWins: Double,
                          rottenTomatoesScore: Double,
                          posterURL: URL) -> (model: MovieItem, json: [String: Any]) {
        let json = [
            "_id": id,
            "name": name,
            "runtimeInMinutes": runtimeInMinutes,
            "budgetInMillions": budgetInMillions,
            "boxOfficeRevenueInMillions": boxOfficeRevenueInMillions,
            "academyAwardNominations": academyAwardNominations,
            "academyAwardWins": academyAwardWins,
            "rottenTomatoesScore": rottenTomatoesScore,
            "posterURL": posterURL.absoluteString
        ].compactMapValues { $0 }
        
        let model = MovieItem(
            id: id,
            name: name,
            runtimeInMinutes: runtimeInMinutes,
            budgetInMillions: budgetInMillions,
            boxOfficeRevenueInMillions: boxOfficeRevenueInMillions,
            academyAwardNominations: academyAwardNominations,
            academyAwardWins: academyAwardWins,
            rottenTomatoesScore: rottenTomatoesScore,
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
}
