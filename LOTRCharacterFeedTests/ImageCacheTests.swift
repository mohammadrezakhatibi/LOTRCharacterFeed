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
    
    private class LoadImageDataTask: CharacterImageDataLoaderTask {
        func cancel() { }
        
    }
    
    typealias Result = Swift.Result<(Data), Error>
    
    @discardableResult
    func loadImageData(url: URL, completion: @escaping (Result) -> Void) -> CharacterImageDataLoaderTask? {
        var task: CharacterImageDataLoaderTask?
        if let cached = retrieveImageData(for: url) {
            completion(.success(cached))
            return task
        }
        
        task = loader.loadImageData(url: url) { [weak self] result in
            switch result {
                case let .success(data):
                    let url = NSURL(string: url.absoluteString)!
                    self?.cache.setObject(NSData(data: data), forKey: url)
                    completion(.success(data))
                case let .failure(error):
                    completion(.failure(error))
            }
        }
        return task
    }
    
    func retrieveImageData(for url: URL) -> Data?  {
        guard let url = NSURL(string: url.absoluteString),
          let nsData = self.cache.object(forKey: url) else {
            return .none
          }
        let data = Data(referencing: nsData)
        return data
    }
}

final class ImageCacheTests: XCTestCase {

    func test_init_doesNotRequestToLoadImage() {
        let (_, loader, _) = makeSUT()
        
        XCTAssertEqual(loader.receivedURLs, [])
    }
    
    func test_loadImageData_sendsURLRequestToLoaderWhenCacheNotAvailable() {
        let url = anyURL()
        let (sut, loader, _) = makeSUT()
        
        sut.loadImageData(url: url) { _ in }
        
        XCTAssertEqual(loader.receivedURLs, [url])
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let url = anyURL()
        let error = anyNSError()
        
        let (sut, loader, _) = makeSUT()
        
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
        let anyData = anyData()
        
        let (sut, loader, cache) = makeSUT()
        
        sut.loadImageData(url: url, completion: { _ in })
        
        loader.complete(with: anyData)
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.receivedURLs, [url])
        XCTAssertEqual(cache.receivedDatas, [anyData])
    }
    
    func test_retrieveData_deliversDataWhenCachedImageIsAvailable() {
        let url = anyURL()
        let anyData = anyData()
        
        let (sut, loader, cache) = makeSUT()
        
        sut.loadImageData(url: url, completion: { _ in })
        
        loader.complete(with: anyData)
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.receivedURLs, [url])
        XCTAssertEqual(cache.receivedDatas, [anyData])
        
        var receivedData: Data?
        receivedData = sut.retrieveImageData(for: url)
        
        XCTAssertEqual(receivedData, anyData)
    }
    
    func test_retrieveData_deliversNoneDataWhenCachedImageIsNotAvailable() {
        let url = anyURL()
        let (sut, _, _) = makeSUT()
        
        var receivedData: Data?
        receivedData = sut.retrieveImageData(for: url)
        
        XCTAssertNil(receivedData)
    }
    
    func test_loadData_deliversCachedImageWhenCachedImageIsAvailable() {
        let url = anyURL()
        let anyData = anyData()
        let (sut, loader, cache) = makeSUT()

        sut.loadImageData(url: url, completion: { _ in })
        loader.complete(with: anyData)
        
        sut.loadImageData(url: url, completion: { _ in })
    
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.retrievedURLs, [url])
        XCTAssertEqual(cache.retrievedDatas, [anyData])
    }
    
    // MARK: - Helper
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCache, loader: CharacterImageDataLoaderSpy, cache: NSCacheSpy) {
        let loader = CharacterImageDataLoaderSpy()
        let cache = NSCacheSpy()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        let sut = ImageCache(loader: loader, cache: cache)
        
        trackingForMemoryLeaks(loader, file: file, line: line)
        trackingForMemoryLeaks(cache, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader, cache)
    }
    
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
        private var retrievalMessages = [URL: Data]()
    
        var receivedURLs: [URL] {
            return messages.map { $0.key }
        }
        
        var receivedDatas: [Data] {
            return messages.map { $0.value }
        }
        
        var retrievedURLs: [URL] {
            return retrievalMessages.map { $0.key }
        }
        
        var retrievedDatas: [Data] {
            return retrievalMessages.map { $0.value }
        }
        
        override func setObject(_ obj: NSData, forKey key: NSURL) {
            let url = URL(string: key.absoluteString!)
            let data = Data(referencing: obj)
            messages[url!] = data
        }
        
        override func object(forKey key: NSURL) -> NSData? {
            if let url = URL(string: key.absoluteString!), let data = messages[url] {
                retrievalMessages[url] = data
                let nsData = NSData(data: data)
                return nsData
            }
            return nil
        }
    }
}
