//
//  URLSessionHTTPClient.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/27/22.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {
    public func get(from request: Request, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        var urlRequest = URLRequest(url: request.url)
        urlRequest.httpBody = request.body
        urlRequest.httpMethod = "GET"
        _ = request.header?.map { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        
        let task = session
            .dataTask(with: urlRequest, completionHandler: { data, response, error in
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

}
