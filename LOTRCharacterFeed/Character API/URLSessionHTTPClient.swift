//
//  URLSessionHTTPClient.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/27/22.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentationError: Error {}
    
    private class Task: HTTPClientTask {
        
        let wrapped: URLSessionTask
        
        init(wrapped: URLSessionTask) {
            self.wrapped = wrapped
        }
        
        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        let task = session
            .dataTask(with: url, completionHandler: { data, response, error in
                guard let data = data, let response = response as? HTTPURLResponse else {
                    if let error {
                        completion(.failure(error))
                    } else {
                        completion(.failure(UnexpectedValueRepresentationError()))
                    }
                    return
                }
                completion(.success((data, response)))
            })
        task.resume()
        
        return Task(wrapped: task)
    }
}
