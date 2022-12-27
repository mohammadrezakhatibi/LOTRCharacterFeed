//
//  URLSessionHTTPClientTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/27/22.
//

import XCTest

protocol URLSessionTask {
    func resume()
}

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask
}

final class URLSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
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
    
    private class URLSessionSpy: HTTPSession {
        var requestedURLs = [URL]()
        var stubs = [URL: URLSessionTask]()
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
            requestedURLs.append(url)
            return stubs[url] ?? FakeURLSessionTask()
        }
        
        func stub(url: URL, task: URLSessionTask) {
            stubs[url] = task
        }
    }
    
    private class FakeURLSessionTask: URLSessionTask {
        func resume() {
            
        }
    }
    
    private class URLSessionTaskSpy: URLSessionTask {
        var resumeCallCount = 0
        func resume() {
            resumeCallCount += 1
        }
    }
}
