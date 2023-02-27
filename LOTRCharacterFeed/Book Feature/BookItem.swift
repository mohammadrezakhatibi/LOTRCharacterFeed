import Foundation

public struct BookItem: Codable, Hashable {
    public let id: String
    public let name: String
    public let publisher: String
    public let barcode: String
    public let coverURL: URL
    
    public init(id: String, name: String, publisher: String, barcode: String, coverURL: URL) {
        self.id = id
        self.name = name
        self.publisher = publisher
        self.barcode = barcode
        self.coverURL = coverURL
    }
}
