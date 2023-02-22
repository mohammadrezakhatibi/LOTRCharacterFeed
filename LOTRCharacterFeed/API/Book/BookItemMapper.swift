import Foundation

public struct BookItemMapper {
    
    private struct Root: Codable {
        var docs: [RemoteBookItem]
        var total: Int
        var limit: Int
        var offset : Int
        var page: Int
        var pages: Int
        
        var books: [BookItem] {
            docs.map {
                BookItem(
                    id: $0._id,
                    name: $0.name,
                    publisher: $0.publisher,
                    ISBN13: $0.ISBN13,
                    coverURL: $0.coverURL)
            }
        }
    }
    
    enum Error: Swift.Error {
        case unauthorized
        case invalidData
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> [BookItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.books
    }
}
