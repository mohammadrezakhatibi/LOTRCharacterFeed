//
//  CharacterLoader.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/21/22.
//

import Foundation

public protocol CharacterLoader {
    associatedtype Resource
    typealias Result = Swift.Result<Resource, Error>
    
    func load(completion: @escaping (Result) -> Void)
}
