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
        session
            .dataTask(with: url, completionHandler: { _,_,_ in })
            .resume()
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
    
    func test_getFromURL_resumeDataTaskWithURL() {
        let url = anyURL()
        let session = URLSessionSpy()
        let task = URLSessionTaskSpy()
        let sut = URLSessionHTTPClient(session: session)
        
        session.stub(url: url, task: task)
        
        sut.get(url: url)
        
        XCTAssertEqual(task.resumeCallCount, 1)
    }

    // MARK: - Helpers
    
    private class URLSessionSpy: URLSession {
        var requestedURLs = [URL]()
        var stubs = [URL: URLSessionDataTask]()
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURLs.append(url)
            return stubs[url] ?? FakeURLSessionTask()
        }
        
        func stub(url: URL, task: URLSessionDataTask) {
            stubs[url] = task
        }
    }
    
    private class FakeURLSessionTask: URLSessionDataTask {
        override func resume() {
            
        }
    }
    
    private class URLSessionTaskSpy: URLSessionDataTask {
        var resumeCallCount = 0
        override func resume() {
            resumeCallCount += 1
        }
    }
}
