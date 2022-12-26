//
//  RemoteCharacterImageDataLoader.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/26/22.
//

import Foundation

public protocol CharacterImageDataLoaderTask {
    func cancel()
}

public final class RemoteCharacterImageDataLoader {
    
    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPClientTaskWrapper: CharacterImageDataLoaderTask {
        private var completion: ((RemoteCharacterImageDataLoader.Result) -> Void)?

        var wrapped: HTTPClientTask?

        init(_ completion: @escaping (RemoteCharacterImageDataLoader.Result) -> Void) {
            self.completion = completion
        }

        func complete(with result: RemoteCharacterImageDataLoader.Result) {
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
    
    public typealias Result = Swift.Result<(Data), Error>
    
    @discardableResult
    public func loadImageData(url: URL, completion: @escaping (RemoteCharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
        let task = HTTPClientTaskWrapper(completion)
        task.wrapped = client.get(from: url, completion: { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in
                    Error.connectivity
                }
                .flatMap{ data, response in
                    if response.statusCode == 200, !data.isEmpty {
                        return .success(data)
                    } else {
                        return .failure(.invalidData)
                    }
                }
            )
        })
        return task
    }
}
