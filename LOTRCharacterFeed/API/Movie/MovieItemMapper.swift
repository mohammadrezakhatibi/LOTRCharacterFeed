import Foundation

public struct MovieItemMapper {
    
    private struct Root: Codable {
        var docs: [RemoteMovieItem]
        var total: Int
        var limit: Int
        var offset : Int
        var page: Int
        var pages: Int
        
        var movies: [MovieItem] {
            docs.map {
                MovieItem(
                    id: $0._id,
                    name: $0.name,
                    runtimeInMinutes: $0.runtimeInMinutes,
                    budgetInMillions: $0.budgetInMillions,
                    boxOfficeRevenueInMillions: $0.boxOfficeRevenueInMillions,
                    academyAwardNominations: $0.academyAwardNominations,
                    academyAwardWins: $0.academyAwardWins,
                    rottenTomatoesScore: $0.rottenTomatoesScore,
                    posterURL: $0.posterURL)
            }
        }
    }
    
    enum Error: Swift.Error {
        case unauthorized
        case invalidData
    }
    
    public static func map(_ data: Data, response: HTTPURLResponse) throws -> [MovieItem] {
        guard response.isOK, let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw Error.invalidData
        }
        return root.movies
    }
}
