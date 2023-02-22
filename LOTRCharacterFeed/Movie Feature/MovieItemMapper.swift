import Foundation

public struct MovieItemMapper {
    
    private struct Root: Codable {
        let docs: [RemoteMovieItem]
        let total: Int
        let limit: Int
        let offset : Int
        let page: Int
        let pages: Int
        
        var movies: [MovieItem] {
            docs.map {
                MovieItem(
                    id: $0._id,
                    name: $0.name,
                    runtime: $0.runtimeInMinutes,
                    budget: $0.budgetInMillions,
                    revenue: $0.boxOfficeRevenueInMillions,
                    academyAwardNominations: $0.academyAwardNominations,
                    academyAwardWins: $0.academyAwardWins,
                    score: $0.rottenTomatoesScore,
                    posterURL: $0.posterURL)
            }
        }
    }
    
    public enum Error: Swift.Error {
        case invalidData
        case connectivity
        case unauthorized
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> [MovieItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw response.isUnauthorized
            ? RemoteMovieLoader.Error.unauthorized
            : RemoteMovieLoader.Error.invalidData
        }
        return root.movies
    }
}
