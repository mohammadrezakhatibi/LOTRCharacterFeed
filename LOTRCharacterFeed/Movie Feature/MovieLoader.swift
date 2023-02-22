import Foundation

public protocol MovieLoader {
    typealias Result = Swift.Result<[MovieItem], Error>
    
    func load(completion: @escaping (Result) -> Void)
}
