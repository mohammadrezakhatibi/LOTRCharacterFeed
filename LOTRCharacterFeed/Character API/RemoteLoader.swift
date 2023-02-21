import Foundation

open class RemoteLoader<Resource> {
    let request: URLRequest
    let client: HTTPClient
    let mapper: Mapper
    
    public typealias Mapper = (Data, HTTPURLResponse) throws -> Resource
    public typealias Result = Swift.Result<Resource, RemoteLoader.Error>
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
        case unauthorized
    }
    
    public init(request: URLRequest, client: HTTPClient, mapper: @escaping Mapper) {
        self.request = request
        self.client = client
        self.mapper = mapper
    }
    
    open func load(completion: @escaping (Result) -> Void) {
        client.get(from: request) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
                case let .success((data, response)):
                    completion(self.map(data, with: response))
                case .failure:
                    completion(.failure(RemoteLoader.Error.connectivity))
            }
        }
    }
    
    private func map(_ data: Data, with response: HTTPURLResponse) -> Result {
        guard !response.isUnauthorized else {
            return .failure(Error.unauthorized)
        }
        do {
            return .success(try mapper(data, response))
        } catch {
            return .failure(Error.invalidData)
        }
    }
}
