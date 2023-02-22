//
//  ImageCache.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 1/6/23.
//

import Foundation
import UIKit

public final class ImageCacheLoader {
    private let loader: ImageDataLoader
    private let cache: NSCache<NSURL, NSData>
    private let imageFileCache: ImageFileCache
    
    public init(loader: ImageDataLoader, cache: NSCache<NSURL, NSData>, imageFileCache: ImageFileCache) {
        self.loader = loader
        self.cache = cache
        self.imageFileCache = imageFileCache
    }
    
    private class LoadImageDataTask: CharacterImageDataLoaderTask {
        func cancel() { }
        
    }
    
    public typealias Result = Swift.Result<(Data), Error>
    
    @discardableResult
    public func loadImageData(url: URL, completion: @escaping (Result) -> Void) -> CharacterImageDataLoaderTask? {

        var task: CharacterImageDataLoaderTask?
        if let cached = retrieveImageData(for: url) {
            completion(.success(cached))
            return task
        }
        
        task = loader.loadImageData(url: url) { [weak self] result in
            switch result {
                case let .success(data):
                    let nsURL = NSURL(string: url.absoluteString)!
                    self?.cache.setObject(NSData(data: data), forKey: nsURL)
                    do {
                        try? self?.imageFileCache.save(data: data, fileName: url)
                    }
                    completion(.success(data))
                case let .failure(error):
                    completion(.failure(error))
            }
        }
        return task
    }
    
    public func retrieveImageData(for url: URL) -> Data?  {
        guard let url = NSURL(string: url.absoluteString),
          let nsData = self.cache.object(forKey: url) else {
            return .none
          }
        let data = Data(referencing: nsData)
        return data
    }
}
