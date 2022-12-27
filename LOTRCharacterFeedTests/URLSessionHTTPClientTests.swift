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
    
    func get(url: URL) {
        session.dataTask(with: url, completionHandler: { _,_,_ in })
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_init_doesNotSendAnyMessages() {
        let session = URLSessionSpy()
        let _ = URLSessionHTTPClient(session: session)
        
        XCTAssertTrue(session.requestedURLs.isEmpty)
    }
    
    func test_getFromURL_requestsDataFromURL() {
        let url = anyURL()
        let session = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: session)
            
        sut.get(url: url)
        
        XCTAssertEqual(session.requestedURLs, [url])
    }

    
    private class URLSessionSpy: URLSession {
        var requestedURLs = [URL]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            return FakeURLSessionTask()
        }
    }
    
    private class FakeURLSessionTask: URLSessionDataTask {
        
    }
}
