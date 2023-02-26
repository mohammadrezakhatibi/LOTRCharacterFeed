import Foundation

public protocol BooksLoader {
    typealias Result = Swift.Result<[BookItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
