//
//  CharacterFeedModel.swift
//  LOTRCharacterFeediOS
//
//  Created by mohammadreza on 1/3/23.
//

import Foundation
import LOTRCharacterFeed

enum CharacterFeedModel {
    enum LoadCharacters {
        struct Request { }
        
        struct Response {
            var characters: [CharacterItem]
        }
        
        struct ViewModel {
            var feedViewModel: [CharacterFeedViewModel]
        }
    }
}
