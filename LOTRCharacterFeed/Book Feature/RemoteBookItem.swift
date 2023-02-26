import Foundation

struct RemoteBookItem: Codable {
    public let _id: String
    public let name: String
    public let publisher: String
    public let ISBN13: String
    public let coverURL: URL
    
    public init(_id: String, name: String, publisher: String, ISBN13: String, coverURL: URL) {
        self._id = _id
        self.name = name
        self.publisher = publisher
        self.ISBN13 = ISBN13
        self.coverURL = coverURL
    }
}
