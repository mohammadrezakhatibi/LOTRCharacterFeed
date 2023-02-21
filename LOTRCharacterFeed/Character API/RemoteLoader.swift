import Foundation

public final class RemoteLoader: CharacterLoader {
    
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
                    completion(.failure(RemoteLoader.Error.connectivity))
                case let .success((data, response)):
                    guard let self = self else { return }
                    completion(self.map(data, with: response))
            }
        }
    }
    
    private func map(_ data: Data, with response: HTTPURLResponse) -> CharacterLoader.Result {
        do {
            let items = try ItemMapper.map(data, response: response)
            return .success(items.toModel())
        } catch(let error) {
            return .failure(error)
        }
    }
}

public struct ItemMapper {
    
    private struct Root: Codable {
        var docs: [RemoteCharacterItem]
        var total: Int
        var limit: Int
        var offset : Int
        var page: Int
        var pages: Int
        
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteCharacterItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw response.isUnauthorized
            ? RemoteLoader.Error.unauthorized
            : RemoteLoader.Error.invalidData
        }
        return root.docs
    }
}
