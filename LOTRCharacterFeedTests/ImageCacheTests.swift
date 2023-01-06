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
    let cache: NSCache<NSURL, NSData>
    
    init(loader: CharacterImageDataLoader, cache: NSCache<NSURL, NSData>) {
        self.loader = loader
        self.cache = cache
    }
    
    typealias Result = Swift.Result<(Data), Error>
    
    @discardableResult
    func loadImageData(url: URL, completion: @escaping (Result) -> Void) -> CharacterImageDataLoaderTask {
        let task = loader.loadImageData(url: url) { result in
            switch result {
                case let .success(data):
                    let url = NSURL(string: url.absoluteString)!
                    self.cache.setObject(NSData(data: data), forKey: url)
                    completion(.success(data))
                case let .failure(error):
                    completion(.failure(error))
            }
        }
        return task
    }
    
    func retrieveImageData(for url: URL, completion: @escaping (Data?) -> Void)  {
        let url = NSURL(string: url.absoluteString)!
        if let data = self.cache.object(forKey: url) {
            let data = Data(referencing: data)
            completion(data)
        } else {
            completion(nil)
        }
    }
}

final class ImageCacheTests: XCTestCase {

    func test_init_doesNotRequestToLoadImage() {
        let loader = CharacterImageDataLoaderSpy()
        let cache = NSCacheSpy()
        let _ = ImageCache(loader: loader, cache: cache)
        
        XCTAssertEqual(loader.receivedURLs, [])
    }
    
    func test_loadImageData_sendsURLRequestToLoaderWhenCacheNotAvailable() {
        let url = anyURL()
        let loader = CharacterImageDataLoaderSpy()
        let cache = NSCacheSpy()
        let sut = ImageCache(loader: loader, cache: cache)
        
        sut.loadImageData(url: url) { _ in }
        
        XCTAssertEqual(loader.receivedURLs, [url])
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let url = anyURL()
        let error = anyNSError()
        let loader = CharacterImageDataLoaderSpy()
        let cache = NSCacheSpy()
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
        XCTAssertEqual(receivedError as NSError?, error)
    }
    
    func test_loadImageData_savesDataOnCacheOnLoaderSuccessfulLoad() {
        let url = anyURL()
        let loader = CharacterImageDataLoaderSpy()
        let cache = NSCacheSpy()
        let sut = ImageCache(loader: loader, cache: cache)
        
        let anyData = anyData()
        
        sut.loadImageData(url: url, completion: { _ in })
        
        loader.complete(with: anyData)
        
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.receivedURLs, [url])
        XCTAssertEqual(cache.receivedDatas, [anyData])
    }
    
    func test_retrieveData_deliversDataWhenCachedImageIsAvailable() {
        let url = anyURL()
        let loader = CharacterImageDataLoaderSpy()
        let cache = NSCacheSpy()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        let sut = ImageCache(loader: loader, cache: cache)
        
        let anyData = anyData()
        
        sut.loadImageData(url: url, completion: { _ in })
        
        loader.complete(with: anyData)
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.receivedURLs, [url])
        XCTAssertEqual(cache.receivedDatas, [anyData])
        
        let exp = expectation(description: "Wait for retrieve completion")
        var receivedData: Data?
        sut.retrieveImageData(for: url) { data in
            receivedData = data
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedData, anyData)
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
        
        func complete(with data: Data, at index: Int = 0) {
            messages[index].completion(.success(data))
        }
    }
    
    
    class NSCacheSpy: NSCache<NSURL,NSData> {
        private var messages = [URL: Data]()
    
        var receivedURLs: [URL] {
            return messages.map { $0.key }
        }
        
        var receivedDatas: [Data] {
            return messages.map { $0.value }
        }
        
        override func setObject(_ obj: NSData, forKey key: NSURL) {
            let url = URL(string: key.absoluteString!)
            let data = Data(referencing: obj)
            messages[url!] = data
        }
        
        override func object(forKey key: NSURL) -> NSData? {
            if let url = URL(string: key.absoluteString!), let data = messages[url] {
                let nsData = NSData(data: data)
                return nsData
            }
            return nil
        }
    }
}
