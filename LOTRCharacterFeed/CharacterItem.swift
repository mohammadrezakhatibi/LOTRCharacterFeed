//
//  CharacterItem.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/21/22.
//

import Foundation

public struct CharacterItem: Codable, Equatable {
    var _id: String
    var height: String
    var race: String
    var gender: String
    var birth: String
    var spouse: String
    var death: String
    var realm: String
    var hair: String
    var name: String
    var wikiURL: String
}
