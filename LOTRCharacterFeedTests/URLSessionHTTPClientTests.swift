//
//  URLSessionHTTPClientTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/27/22.
//

import XCTest
import LOTRCharacterFeed

final class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
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

    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override class func tearDown() {
        super.tearDown()
        
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURL()
        
        let exp = expectation(description: "Waiting for get completion")
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(url: url, completion: { _ in })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromURL_failsOnRequestError() {
        let receivedError = resultErrorFor(data: nil, response: nil, error: anyNSError())
        
        XCTAssertNotNil(receivedError)
    }

    // MARK: - Helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackingForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: HTTPURLResponse?, error: Error?) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        
        let exp = expectation(description: "Waiting for get completion")
        var receivedError: Error?
        makeSUT().get(url: anyURL()) { result in
            switch result {
                case let .failure(error):
                    receivedError = error
                default:
                    XCTFail("Expecting failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    private class URLProtocolStub: URLProtocol {
        private static var stub: Stub?
        
        private struct Stub {
            let data: Data?
            let response: HTTPURLResponse?
            let error: Error?
            var requestObserver: ((URLRequest) -> Void)?
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
            stub = Stub(data: nil, response: nil, error: nil)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest) -> Void) {
            stub?.requestObserver = observer
        }
        
        static func stub(data: Data?, response: HTTPURLResponse?, error: Error? = nil) {
            stub = Stub(data: data, response: response, error: error, requestObserver: nil)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            stub?.requestObserver?(request)
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
            
        }
        
        override func stopLoading() {
            
        }
    }
}
