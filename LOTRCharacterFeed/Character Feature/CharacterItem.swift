//
//  CharacterItem.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/21/22.
//

import Foundation

public struct CharacterItem: Codable, Equatable {
    public let id: String
    public let height: String
    public let race: String
    public let gender: String?
    public let birth: String
    public let spouse: String
    public let death: String
    public let realm: String
    public let hair: String
    public let name: String
    public let wikiURL: URL?
    public let imageURL: URL
    
    public init(id: String, height: String, race: String, gender: String?, birth: String, spouse: String, death: String, realm: String, hair: String, name: String, wikiURL: URL?, imageURL: URL) {
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
        self.imageURL = imageURL
    }
}
