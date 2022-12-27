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

    func test_getFromURL_failsOnRequestError() {
        URLProtocol.registerClass(URLProtocolStub.self)
        let url = anyURL()
        let error = anyNSError()
        URLProtocolStub.stub(url: url, data: nil, response: nil, error: error)
        
        let sut = URLSessionHTTPClient()
        
        let exp = expectation(description: "Waiting for get completion")
        sut.get(url: url) { result in
            switch result {
                case .failure(let receivedError as NSError?):
                    XCTAssertEqual(receivedError?.domain, error.domain)
                    XCTAssertEqual(receivedError?.code, error.code)
                default:
                    XCTFail("Expecting failure with error \(error), got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }

    // MARK: - Helpers
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            var data: Data?
            var response: HTTPURLResponse?
            var error: Error?
        }
        
        static func stub(url: URL, data: Data?, response: HTTPURLResponse?, error: Error? = nil) {
            stubs[url] = Stub(data: data, response: response, error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else {
                return false
            }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else {
                return
            }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
            
        }
        
        override func stopLoading() {
            
        }
    }
}
