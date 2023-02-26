import Foundation

public final class RemoteBooksLoader: MovieLoader {
    
    public typealias Resource = [MovieItem]
    public typealias Result = Swift.Result<Resource, Swift.Error>
    
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
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: request) { [weak self] result in
            switch result {
                case .failure:
                    completion(.failure(RemoteBooksLoader.Error.connectivity))
                case let .success((data, response)):
                    guard let self = self else { return }
                    completion(self.map(data, with: response))
            }
        }
    }
    
    private func map(_ data: Data, with response: HTTPURLResponse) -> Result {
        do {
            let items = try BooksItemMapper.map(data, response: response)
            return .success(items)
        } catch(let error) {
            return .failure(error)
        }
    }
}
