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

public protocol CharacterImageDataLoader {
    typealias Result = Swift.Result<(Data), Error>
    
    func loadImageData(request: URLRequest, completion: @escaping (Result) -> Void) -> CharacterImageDataLoaderTask
}
