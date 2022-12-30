//
//  HTTPClientSpy.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/26/22.
//

import Foundation
import LOTRCharacterFeed

class HTTPClientSpy: HTTPClient {
    
    func get(from request: LOTRCharacterFeed.Request, completion: @escaping (HTTPClient.Result) -> Void) -> LOTRCharacterFeed.HTTPClientTask {
        completions.append((request.url, completion))
        return TaskSpy { [weak self] in
            self?.canceledURLs.append(request.url)
        }
    }
    
    private var completions = [(url: URL, completion: (HTTPClient.Result) -> Void)]()
    var requestedURLs: [URL] {
        return completions.map { $0.url }
    }
    var canceledURLs = [URL]()
    
    private struct TaskSpy: HTTPClientTask {
        var cancelCallback: () -> Void
        func cancel() {
            cancelCallback()
        }
    }
    
    func complete(with error: Error, at index: Int = 0) {
        completions[index].completion(.failure(error))
    }
    
    func complete(withStatusCode status: Int, data: Data, at index: Int = 0) {
        let response = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: status,
            httpVersion: nil,
            headerFields: nil)!
        
        completions[index].completion(.success((data, response)))
    }
}
