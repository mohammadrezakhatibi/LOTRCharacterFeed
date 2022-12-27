//
//  URLSessionHTTPClientTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/27/22.
//

import XCTest
import LOTRCharacterFeed

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
    
    func get(url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        session
            .dataTask(with: url, completionHandler: { _,_,error in
                if let error {
                    completion(.failure(error))
                }
            })
            .resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {

    func test_init_doesNotSendAnyMessages() {
        let session = URLSessionSpy()
        let _ = URLSessionHTTPClient(session: session)
        
        XCTAssertTrue(session.requestedURLs.isEmpty)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let url = anyURL()
        let error = anyNSError()
        let session = URLSessionSpy()
        session.stub(url: url, error: error)
        
        
        let sut = URLSessionHTTPClient(session: session)
        
        
        let exp = expectation(description: "Waiting for get completion")
        sut.get(url: url) { result in
            switch result {
                case let .failure(receivedError):
                    XCTAssertEqual(receivedError as NSError?, error)
                default:
                    XCTFail("Expecting failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }

    // MARK: - Helpers
    
    private class URLSessionSpy: HTTPSession {
        var requestedURLs = [URL]()
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            var task: URLSessionTask
            var error: Error?
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
            requestedURLs.append(url)
            guard let stub = stubs[url] else {
                fatalError("Couldn't find stub for \(url)")
            }
            completionHandler(nil, nil, stub.error)
            return stub.task
        }
        
        func stub(url: URL, task: URLSessionTask = FakeURLSessionTask(), error: Error? = nil) {
            stubs[url] = Stub(task: task, error: error)
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
