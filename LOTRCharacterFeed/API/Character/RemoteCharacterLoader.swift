//
//  RemoteFeedLoader.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/23/22.
//

import Foundation

public typealias RemoteCharacterLoader = RemoteLoader<[CharacterItem]>

public extension RemoteCharacterLoader {
    convenience init(request: URLRequest, client: HTTPClient) {
        self.init(request: request, client: client, mapper: CharacterItemMapper.map)
    }
}
