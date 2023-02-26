import Foundation

public struct BooksItemMapper {
    
    private struct Root: Codable {
        let docs: [RemoteBookItem]
        let total: Int
        let limit: Int
        let offset : Int
        let page: Int
        let pages: Int
        
        var books: [BookItem] {
            docs.map {
                BookItem(
                    id: $0._id,
                    name: $0.name,
                    publisher: $0.publisher,
                    barcode: $0.ISBN13,
                    coverURL: $0.coverURL)
            }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
        case unauthorized
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> [BookItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw response.isUnauthorized
            ? RemoteBooksLoader.Error.unauthorized
            : RemoteBooksLoader.Error.invalidData
        }
        return root.books
    }
}
