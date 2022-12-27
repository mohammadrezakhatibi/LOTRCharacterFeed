//
//  URLSessionHTTPClientTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/27/22.
//

import XCTest

final class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_init_doesNotSendAnyMessages() {
        let session = URLSessionSpy()
        let _ = URLSessionHTTPClient(session: session)
        
        XCTAssertTrue(session.requestedURLs.isEmpty)
    }

    
    private class URLSessionSpy: URLSession {
        var requestedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            
            return FakeURLSessionTask()
        }
    }
    
    private class FakeURLSessionTask: URLSessionDataTask {
        
    }
}
