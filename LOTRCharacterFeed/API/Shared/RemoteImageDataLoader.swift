//
//  RemoteCharacterImageDataLoader.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/26/22.
//

import Foundation

public final class RemoteImageDataLoader: ImageDataLoader {
    
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: CharacterImageDataLoaderTask {
        private var completion: ((ImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (ImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: ImageDataLoader.Result) {
            completion?(result)
        }

        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }

        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        let request = URLRequest(url: url)
        task.wrapped = client.get(from: request, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in
                    Error.connectivity
                }
                .flatMap{ data, response in
                    if response.statusCode == 200, !data.isEmpty {
                        return .success(data)
                    } else {
                        return .failure(Error.invalidData)
                    }
                }
            )
        })
        return task
    }
}


