//
//  CharacterFeedWorker.swift
//  LOTRCharacterFeediOS
//
//  Created by mohammadreza on 1/3/23.
//

import Foundation
import LOTRCharacterFeed

protocol CharacterFeedWorker {
    func loadCharacters(completion: @escaping (CharacterLoader.Result) -> Void)
}

final class RemoteCharacterWorker: CharacterFeedWorker {
    
    let loader: CharacterLoader
    
    init(loader: CharacterLoader) {
        self.loader = loader
    }
    
    func loadCharacters(completion: @escaping (CharacterLoader.Result) -> Void) {
        loader.load(completion: completion)
    }
}
