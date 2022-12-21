//
//  RemoteCharacterLoaderTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/21/22.
//

import XCTest

class HTTPClient {
    var requestedURLs: [URL] = []
}

final class RemoteCharacterLoader {
    
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
}

final class RemoteCharacterLoaderTests: XCTestCase {

    func test_init_doesNotRequestDataFromURL() {
        let url = URL(string: "http://any-url.com")!
        
        let client = HTTPClient()
        let _ = RemoteCharacterLoader(url: url, client: client)
        
        XCTAssertEqual(client.requestedURLs.count, 0)
    }

}
