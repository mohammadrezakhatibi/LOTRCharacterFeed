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
                XCTAssertEqual(items.count, 25)
                
                items.enumerated().forEach { index, item in
                    XCTAssertEqual(item.id, id(at: index))
                    XCTAssertEqual(item.name, name(at: index))
                }
                
                XCTAssertEqual(items.first?.name, "Aragorn II Elessar")
                XCTAssertEqual(items.first?.id, "5cd99d4bde30eff6ebccfbe6")
                
                XCTAssertEqual(items[1].name, "Frodo Baggins")
                XCTAssertEqual(items[1].id, "5cd99d4bde30eff6ebccfc15")
                
                XCTAssertEqual(items.last?.name, "Elrond")
                XCTAssertEqual(items.last?.id, "5cd99d4bde30eff6ebccfcc8")
                
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
        var url: URL = URL(string: "https://lokomond.com/lotr/lotr_characters.json")!
        var header: [String : String]? = ["Authorization" : "Bearer 4FVcNlyhfHkLwFuqo-YP"]
        
        func create() -> URLRequest {
            var request = URLRequest(url: url)
            request.httpMethod = method
            request.allHTTPHeaderFields = header
            return request
        }
    }
    
    private func id(at index: Int) -> String {
        return [
            "5cd99d4bde30eff6ebccfbe6",
            "5cd99d4bde30eff6ebccfc15",
            "5cd99d4bde30eff6ebccfc38",
            "5cd99d4bde30eff6ebccfea0",
            "5cd99d4bde30eff6ebccfea4",
            "5cd99d4bde30eff6ebccfea5",
            "5cd9d5a0844dc4c55e47afef",
            "5cd99d4bde30eff6ebccfc57",
            "5cd99d4bde30eff6ebccfd81",
            "5cd99d4bde30eff6ebccfd23",
            "5cd99d4bde30eff6ebccfd0d",
            "5cd99d4bde30eff6ebccfd06",
            "5cd99d4bde30eff6ebccfe9e",
            "5cd99d4bde30eff6ebccfd82",
            "5cd9d576844dc4c55e47afee",
            "5cd99d4bde30eff6ebccfc07",
            "5cd99d4bde30eff6ebccfcbc",
            "5cdbdecb6dc0baeae48cfa59",
            "5cd99d4bde30eff6ebccfe13",
            "5cd99d4bde30eff6ebccfe2e",
            "5cd99d4bde30eff6ebccfc7c",
            "5cd99d4bde30eff6ebccfea1",
            "5cd99d4bde30eff6ebccfc9a",
            "5cd99d4bde30eff6ebccfe9d",
            "5cd99d4bde30eff6ebccfcc8",
        ][index]
    }
    
    private func name(at index: Int) -> String {
        return [
            "Aragorn II Elessar",
            "Frodo Baggins",
            "Bilbo Baggins",
            "Gandalf",
            "Saruman",
            "Sauron",
            "Mouth of Sauron",
            "Boromir",
            "Legolas",
            "Gimli",
            "Samwise Gamgee",
            "Galadriel",
            "Gollum",
            "Isildur",
            "Witch-King of Angmar",
            "Arwen",
            "Elendil",
            "Éowyn",
            "Thranduil",
            "Peregrin Took",
            "Meriadoc Brandybuck",
            "Radagast",
            "Denethor II",
            "Gríma Wormtongue",
            "Elrond",
        ][index]
    }
}
