//
//  CharacterItemMapper.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/23/22.
//

import Foundation

public struct CharacterItemMapper {
    
    private struct Root: Codable {
        var items: [RemoteCharacterItem]
        
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteCharacterItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw response.isUnauthorized
            ? RemoteCharacterLoader.Error.unauthorized
            : RemoteCharacterLoader.Error.invalidData
        }
        return root.items
    }
}
