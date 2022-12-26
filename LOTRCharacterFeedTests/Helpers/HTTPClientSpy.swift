//
//  HTTPClientSpy.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/26/22.
//

import Foundation
import LOTRCharacterFeed

class HTTPClientSpy: HTTPClient {
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
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask  {
        completions.append((url, completion))
        return TaskSpy { [weak self] in
            self?.canceledURLs.append(url)
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
