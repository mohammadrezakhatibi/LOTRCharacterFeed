//
//  CharacterItem.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/21/22.
//

import Foundation

public struct CharacterItem: Codable, Equatable {
    var id: String
    var height: String
    var race: String
    var gender: String
    var birth: String
    var spouse: String
    var death: String
    var realm: String
    var hair: String
    var name: String
    var wikiURL: URL
    
    public init(id: String, height: String, race: String, gender: String, birth: String, spouse: String, death: String, realm: String, hair: String, name: String, wikiURL: URL) {
        self.id = id
        self.height = height
        self.race = race
        self.gender = gender
        self.birth = birth
        self.spouse = spouse
        self.death = death
        self.realm = realm
        self.hair = hair
        self.name = name
        self.wikiURL = wikiURL
    }
}
