//
//  RemoteCharacterItem.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/23/22.
//

import Foundation

public struct RemoteCharacterItem: Codable {
    public var _id: String
    public var height: String
    public var race: String
    public var gender: String
    public var birth: String
    public var spouse: String
    public var death: String
    public var realm: String
    public var hair: String
    public var name: String
    public var wikiUrl: URL
    public var imageUrl: URL

    public init(id: String, height: String, race: String, gender: String, birth: String, spouse: String, death: String, realm: String, hair: String, name: String, wikiUrl: URL, imageUrl: URL) {
        self._id = id
        self.height = height
        self.race = race
        self.gender = gender
        self.birth = birth
        self.spouse = spouse
        self.death = death
        self.realm = realm
        self.hair = hair
        self.name = name
        self.wikiUrl = wikiUrl
        self.imageUrl = imageUrl
    }
}
