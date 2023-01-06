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
    
    func loadImageData(url: URL) {
        _ = loader.loadImageData(url: url) { _ in }
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
        
        sut.loadImageData(url: anyURL())
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.numberOfCalls, 0)
    }
    
    // MARK: - Helper
    
    private final class CharacterImageDataLoaderSpy: CharacterImageDataLoader {
        
        var receivedURLs = [URL]()
        
        private class Task: CharacterImageDataLoaderTask {
            func cancel() {
                
            }
        }
        
        func loadImageData(url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
            receivedURLs.append(url)
            return Task()
        }
    }
    
    private final class URLCacheSpy: URLCache {
        var numberOfCalls = 0
        
    }
}
