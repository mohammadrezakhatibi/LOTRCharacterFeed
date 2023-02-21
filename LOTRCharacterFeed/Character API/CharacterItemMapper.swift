//
//  CharacterItemMapper.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/23/22.
//

import Foundation

public struct CharacterItemMapper {
    
    private struct Root: Codable {
        var docs: [RemoteCharacterItem]
        var total: Int
        var limit: Int
        var offset : Int
        var page: Int
        var pages: Int
        
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> [CharacterItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw response.isUnauthorized
            ? RemoteCharacterLoader.Error.unauthorized
            : RemoteCharacterLoader.Error.invalidData
        }
        return root.docs.toModel()
    }
}

public extension Array where Element == RemoteCharacterItem {
    func toModel() -> [CharacterItem] {
        return map {
            CharacterItem(
                id: $0._id,
                height: $0.height,
                race: $0.race,
                gender: $0.gender,
                birth: $0.birth,
                spouse: $0.spouse,
                death: $0.death,
                realm: $0.realm,
                hair: $0.hair,
                name: $0.name,
                wikiURL: $0.wikiUrl,
                imageURL: $0.imageUrl
            )
        }
    }
}
