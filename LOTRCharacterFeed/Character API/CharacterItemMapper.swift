import Foundation

public struct CharacterItemMapper {
    
    private struct Root: Codable {
        let docs: [RemoteCharacterItem]
        let total: Int
        let limit: Int
        let offset : Int
        let page: Int
        let pages: Int
        
        var characters: [CharacterItem] {
            docs.map {
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
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
        case unauthorized
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> [CharacterItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw response.isUnauthorized
            ? RemoteCharacterLoader.Error.unauthorized
            : RemoteCharacterLoader.Error.invalidData
        }
        return root.characters
    }
}
