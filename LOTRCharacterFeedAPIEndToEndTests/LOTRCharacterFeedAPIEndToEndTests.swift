//
//  LOTRCharacterFeedAPIEndToEndTests.swift
//  LOTRCharacterFeedAPIEndToEndTests
//
//  Created by Mohammadreza on 12/26/22.
//

import XCTest
import LOTRCharacterFeed

final class LOTRCharacterFeedAPIEndToEndTests: XCTestCase {

    func test() {
        switch getFeedResult() {
            case let .success(items)?:
                XCTAssertEqual(items.count, 933)
                
                XCTAssertEqual(items.first?.name, "Adanel")
                XCTAssertEqual(items.first?.id, "5cd99d4bde30eff6ebccfbbe")
                
                XCTAssertEqual(items[1].name, "Adrahil I")
                XCTAssertEqual(items[1].id, "5cd99d4bde30eff6ebccfbbf")
                
                XCTAssertEqual(items.last?.name, "Éothain")
                XCTAssertEqual(items.last?.id, "5cdbe73516d496d2c2940848")
                
            case let .failure(error):
                XCTFail("Expected success, got failure with \(error)")
                
            default:
                XCTFail("Expected success, got no result")
        }
    }

    
    private var feedTestServerURL: URL {
        return URL(string: "https://the-one-api.dev/v2/")!
    }
    
    func getFeedResult(file: StaticString = #filePath,
                       line: UInt = #line) -> CharacterLoader.Result? {
        
        let url = feedTestServerURL.appendingPathComponent("character/")
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let r = CharacterRequest(url: url)
        let loader = RemoteCharacterLoader(request: r, client: client)
        
        trackingForMemoryLeaks(client, file: file, line: line)
        trackingForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: CharacterLoader.Result?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        return receivedResult
        
    }
    
    private class CharacterRequest: Request {
        var url: URL
        var body: Data? = nil
        var header: [String : String]? = ["Authentication" : "Bearer 4FVcNlyhfHkLwFuqo-YP", "Cache-Control": "no-cache"]
        
        init(url: URL) {
            self.url = url
        }
    }
}
