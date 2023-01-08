//
//  ImageCache.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 1/6/23.
//

import Foundation
import UIKit

public final class ImageCacheLoader {
    private let loader: CharacterImageDataLoader
    private let cache: NSCache<NSURL, NSData>
    
    public init(loader: CharacterImageDataLoader, cache: NSCache<NSURL, NSData>) {
        self.loader = loader
        self.cache = cache
    }
    
    private class LoadImageDataTask: CharacterImageDataLoaderTask {
        func cancel() { }
        
    }
    
    public typealias Result = Swift.Result<(Data), Error>
    
    @discardableResult
    public func loadImageData(url: URL, completion: @escaping (Result) -> Void) -> CharacterImageDataLoaderTask? {
//        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        print(directory)
//        
//        let filename = url.absoluteString.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: ":", with: "")
//        let fileURL = directory.appendingPathComponent(filename)
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
//                    do {
//                        try data.write(to: fileURL)
//                    } catch {
//                        completion(.failure(error))
//                        return
//                    }
                    completion(.success(data))
                case let .failure(error):
                    completion(.failure(error))
            }
        }
        return task
    }
    
    public func retrieveImageData(for url: URL) -> Data?  {        
//        let filename = url.absoluteString.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: ":", with: "")
//        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory
//
//        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
//        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)
//
//        if let dirPath = paths.first {
//            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(filename)
//            let image = UIImage(contentsOfFile: imageUrl.path)
//            return image?.jpegData(compressionQuality: 1)
//
//        }
        
        
        guard let url = NSURL(string: url.absoluteString),
          let nsData = self.cache.object(forKey: url) else {
            return .none
          }
        let data = Data(referencing: nsData)
        return data
    }
}
