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

    func getFeedResult(file: StaticString = #filePath,
                       line: UInt = #line) -> CharacterLoader.Result? {
        
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let request = CharacterRequest().create()
        let loader = RemoteCharacterLoader(request: request, client: client)
        
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
    
    private struct CharacterRequest: RemoteRequest {
        var url: URL = URL(string: "https://the-one-api.dev/v2/character")!
        var header: [String : String]? = ["Authorization" : "Bearer 4FVcNlyhfHkLwFuqo-YP"]
        
        func create() -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.allHTTPHeaderFields = header
            return request
        }
    }
}
