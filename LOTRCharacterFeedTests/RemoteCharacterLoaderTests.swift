//
//  RemoteCharacterLoaderTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/21/22.
//

import XCTest

class HTTPClient {
    private(set) var requestedURLs: [URL] = []
    
    func get(from url: URL) {
        requestedURLs.append(url)
    }
}

final class RemoteCharacterLoader {
    
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    func load() {
        client.get(from: url)
    }
}

final class RemoteCharacterLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "http://any-url.com")!
        
        let client = HTTPClient()
        let _ = RemoteCharacterLoader(url: url, client: client)
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "http://any-url.com")!
        
        let client = HTTPClient()
        let sut = RemoteCharacterLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs.count, 1)
    }

}
