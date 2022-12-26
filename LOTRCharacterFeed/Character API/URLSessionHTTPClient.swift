//
//  URLSessionHTTPClient.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/27/22.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    
    private var session: URLSession
    
    public init(session: URLSession) {
        self.session = session
    }
    
    private struct UnexpectedValueRepresentation: Error {}
    
    private struct URLSessionTaskWrapper: HTTPClientTask {
        let wrapped: URLSessionTask

        func cancel() {
            wrapped.cancel()
        }
    }
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        var request = URLRequest(url: url)
        request.setValue("Bearer 4FVcNlyhfHkLwFuqo-YP", forHTTPHeaderField: "Authorization")
        let task = session.dataTask(with: request) { data, response, error in
            completion(Result {
                if let error {
                    throw error
                } else if let data = data, let response = response as? HTTPURLResponse {
                    return (data, response)
                } else {
                    throw UnexpectedValueRepresentation()
                }
            })
        }
        task.resume()
        return URLSessionTaskWrapper(wrapped: task)
    }
}
