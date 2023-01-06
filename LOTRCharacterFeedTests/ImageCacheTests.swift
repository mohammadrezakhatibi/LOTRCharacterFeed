//
//  ImageCacheTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 1/6/23.
//

import XCTest
import LOTRCharacterFeed


final class ImageCache {
    
    init(loader: CharacterImageDataLoader, cache: URLCache) {
        
    }
}

final class ImageCacheTests: XCTestCase {

    func test_init_doesNotRequestToLoadImage() {
        let loader = CharacterImageDataLoaderSpy()
        let cache = URLCacheSpy(memoryCapacity: 10_000_000, diskCapacity: 100_000_000)
        let _ = ImageCache(loader: loader, cache: cache)
        
        XCTAssertEqual(loader.numberOfCalls, 0)
        XCTAssertEqual(cache.numberOfCalls, 0)
    }
    
    // MARK: - Helper
    
    private final class CharacterImageDataLoaderSpy: CharacterImageDataLoader {
        
        var numberOfCalls = 0
        
        private class Task: CharacterImageDataLoaderTask {
            func cancel() {
                
            }
        }
        
        func loadImageData(url: URL, completion: @escaping (CharacterImageDataLoader.Result) -> Void) -> CharacterImageDataLoaderTask {
            return Task()
        }
    }
    
    private final class URLCacheSpy: URLCache {
        var numberOfCalls = 0
        
        override func cachedResponse(for request: URLRequest) -> CachedURLResponse? {
            <#code#>
        }
    }
}
