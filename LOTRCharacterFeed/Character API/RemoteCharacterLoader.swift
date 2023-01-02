//
//  RemoteFeedLoader.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/23/22.
//

import Foundation

public final class RemoteCharacterLoader: CharacterLoader {
    
    let request: URLRequest
    let client: HTTPClient
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
        case unauthorized
    }
    
    public init(request: URLRequest, client: HTTPClient) {
        self.request = request
        self.client = client
    }
    
    public func load(completion: @escaping (CharacterLoader.Result) -> Void) {
        client.get(from: request) { [weak self] result in
            switch result {
                case .failure:
                    completion(.failure(RemoteCharacterLoader.Error.connectivity))
                case let .success((data, response)):
                    guard let self = self else { return }
                    completion(self.map(data, with: response))
            }
        }
    }
    
    private func map(_ data: Data, with response: HTTPURLResponse) -> CharacterLoader.Result {
        do {
            let items = try CharacterItemMapper.map(data, response: response)
            return .success(items.toModel())
        } catch(let error) {
            return .failure(error)
        }
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
                wikiURL: $0.wikiUrl == nil ? nil : URL(string: $0.wikiUrl!),
                imageURL: $0.ImageURL ?? URL(string: "http://a-url.com")!
            )
        }
    }
}
