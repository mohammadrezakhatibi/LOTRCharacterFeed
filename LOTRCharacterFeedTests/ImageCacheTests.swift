//
//  ImageCacheTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 1/6/23.
//

import XCTest
import LOTRCharacterFeed


final class ImageCache {
    let loader: CharacterImageDataLoader
    let cache: URLCache
    
    init(loader: CharacterImageDataLoader, cache: URLCache) {
        self.loader = loader
        self.cache = cache
    }
    
    typealias Result = Swift.Result<(Data), Error>
    
    func loadImageData(url: URL, completion: @escaping (Result) -> Void) {
        _ = loader.loadImageData(url: url, completion: completion)
    }
    
}

final class ImageCacheTests: XCTestCase {

    func test_init_doesNotRequestToLoadImage() {
        let loader = CharacterImageDataLoaderSpy()
        let cache = URLCacheSpy(memoryCapacity: 10_000_000, diskCapacity: 100_000_000)
        let _ = ImageCache(loader: loader, cache: cache)
        
        XCTAssertEqual(loader.receivedURLs, [])
        XCTAssertEqual(cache.numberOfCalls, 0)
    }
    
    func test_loadImageData_sendsURLRequestToLoaderWhenCacheNotAvailable() {
        let url = anyURL()
        let loader = CharacterImageDataLoaderSpy()
        let cache = URLCacheSpy(memoryCapacity: 10_000_000, diskCapacity: 100_000_000)
        let sut = ImageCache(loader: loader, cache: cache)
        
        sut.loadImageData(url: url) { _ in }
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.numberOfCalls, 0)
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let url = anyURL()
        let error = anyNSError()
        let loader = CharacterImageDataLoaderSpy()
        let cache = URLCacheSpy(memoryCapacity: 10_000_000, diskCapacity: 100_000_000)
        let sut = ImageCache(loader: loader, cache: cache)
        
        let exp = expectation(description: "Wait for load completion")
        var receivedError: Error?
        sut.loadImageData(url: url) { result in
            switch result {
                case let .failure(error):
                    receivedError = error
                default:
                    XCTFail("Expected failure, got \(result) instead")
            }
            exp.fulfill()
        }
        
        loader.complete(with: error)
        
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.numberOfCalls, 0)
        XCTAssertEqual(receivedError as NSError?, error)
    }
    
    // MARK: - Helper
    
    private final class CharacterImageDataLoaderSpy: CharacterImageDataLoader {
        
        var receivedURLs: [URL] {
            return messages.map { $0.url }
        }
        private var messages = [(url: URL, completion: (CharacterImageDataLoader.Result) -> Void)]()
        
        private class Task: CharacterImageDataLoaderTask {
            func cancel() {
                
            }
        }
        
        func loadImageData(url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
    
    private final class URLCacheSpy: URLCache {
        var numberOfCalls = 0
        
    }
}
