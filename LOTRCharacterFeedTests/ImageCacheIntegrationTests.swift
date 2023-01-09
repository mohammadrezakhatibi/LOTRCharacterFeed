//
//  ImageCacheTests.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 1/6/23.
//

import XCTest
import LOTRCharacterFeed

final class ImageCacheIntegrationTests: XCTestCase {

    func test_init_doesNotRequestToLoadImage() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.receivedURLs, [])
    }
    
    func test_loadImageData_sendsURLRequestToLoaderWhenCacheNotAvailable() {
        let url = anyURL()
        let (sut, loader) = makeSUT()
        
        sut.loadImageData(url: url) { _ in }
        
        XCTAssertEqual(loader.receivedURLs, [url])
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let url = anyURL()
        let error = anyNSError()
        
        let (sut, loader) = makeSUT()
        
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
        let cache = NSCacheSpy()
        
        let (sut, loader) = makeSUT(cache: cache)
        
        sut.loadImageData(url: url, completion: { _ in })
        
        loader.complete(with: anyData)
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.messages, [.save(url, anyData)])
    }
    
    func test_retrieveData_deliversDataWhenCachedImageIsAvailable() {
        let url = anyURL()
        let anyData = anyData()
        let cache = NSCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)
        
        sut.loadImageData(url: url, completion: { _ in })
        
        loader.complete(with: anyData)
        
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.messages, [.save(url, anyData)])
        
        var receivedData: Data?
        receivedData = sut.retrieveImageData(for: url)
        
        XCTAssertEqual(receivedData, anyData)
    }
    
    func test_retrieveData_deliversNoneDataWhenCachedImageIsNotAvailable() {
        let url = anyURL()
        let (sut, _) = makeSUT()
        
        var receivedData: Data?
        receivedData = sut.retrieveImageData(for: url)
        
        XCTAssertNil(receivedData)
    }
    
    func test_loadData_deliversCachedImageWhenCachedImageIsAvailable() {
        let url = anyURL()
        let anyData = anyData()
        let cache = NSCacheSpy()
        let (sut, loader) = makeSUT(cache: cache)

        sut.loadImageData(url: url, completion: { _ in })
        loader.complete(with: anyData)
        
        sut.loadImageData(url: url, completion: { _ in })
    
        XCTAssertEqual(loader.receivedURLs, [url])
        XCTAssertEqual(cache.messages, [.save(url, anyData) ,.retrieve(url, anyData)])
    }
    
    // MARK: - Helper
    
    private func makeSUT(cache: NSCacheSpy = .init(), file: StaticString = #filePath, line: UInt = #line) -> (sut: ImageCacheLoader, loader: CharacterImageDataLoaderSpy) {
        let loader = CharacterImageDataLoaderSpy()
        cache.countLimit = 100
        cache.totalCostLimit = 1024 * 1024 * 100
        let sut = ImageCacheLoader(loader: loader, cache: cache, imageFileCache: ImageFileCache(url: anyURL()))
        
        trackingForMemoryLeaks(loader, file: file, line: line)
        trackingForMemoryLeaks(cache, file: file, line: line)
        trackingForMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
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
        enum Message: Equatable {
            case save(URL, Data)
            case retrieve(URL, Data)
        }
        
        var messages = [Message]()
        private var store = [URL: Data]()

        override func setObject(_ obj: NSData, forKey key: NSURL) {
            let url = URL(string: key.absoluteString!)!
            let data = Data(referencing: obj)
            messages.append(.save(url, data))
            store[url] = data
        }
        
        override func object(forKey key: NSURL) -> NSData? {
            if let url = URL(string: key.absoluteString!), let data = store[url] {
                messages.append(.retrieve(url, data))
                let nsData = NSData(data: data)
                return nsData
            }
            return nil
        }
    }
}
