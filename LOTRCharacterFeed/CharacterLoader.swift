//
//  CharacterLoader.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/21/22.
//

import Foundation

protocol CharacterLoader {
    
    typealias Result = Swift.Result<[CharacterItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
    
}
