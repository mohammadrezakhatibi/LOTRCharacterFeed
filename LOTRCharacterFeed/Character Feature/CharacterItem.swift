//
//  CharacterItem.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/21/22.
//

import Foundation

public struct CharacterItem: Codable, Equatable {
    public var id: String
    public var height: String
    public var race: String
    public var gender: String?
    public var birth: String
    public var spouse: String
    public var death: String
    public var realm: String
    public var hair: String
    public var name: String
    public var wikiURL: URL?
    
    public init(id: String, height: String, race: String, gender: String?, birth: String, spouse: String, death: String, realm: String, hair: String, name: String, wikiURL: URL?) {
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
