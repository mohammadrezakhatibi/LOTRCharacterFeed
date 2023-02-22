//
//  CharacterImageDataLoaderTask.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/26/22.
//

import Foundation

public protocol CharacterImageDataLoaderTask {
    func cancel()
}

public protocol ImageDataLoader {
    typealias Result = Swift.Result<(Data), Error>
    
    func loadImageData(url: URL, completion: @escaping (Result) -> Void) -> CharacterImageDataLoaderTask
}
