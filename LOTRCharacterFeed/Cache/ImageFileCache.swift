//
//  ImageFileCache.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 1/9/23.
//

import Foundation

public final class ImageFileCache {
    private let fileManager: FileManager
    
    enum Error: Swift.Error {
        case incompleteSaving
    }
    
    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }
    
    public func save(data: Data, fileName: URL) throws {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = fileName.absoluteString
            .replacingOccurrences(of: "/", with: "")
            .replacingOccurrences(of: ":", with: "")
        let fileURL = directory.appendingPathComponent(filename)
        
        do {
            try data.write(to: fileURL)
        } catch {
            throw Error.incompleteSaving
        }
    }
    
    public func retrieve(from url: URL) -> Data? {
        let filename = url.absoluteString.replacingOccurrences(of: "/", with: "").replacingOccurrences(of: ":", with: "")
        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(filename)
            do {
                let data = try? Data(contentsOf: imageUrl)
                return data
            }
        }
        return nil
    }
}
