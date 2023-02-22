import Foundation

public struct MovieItem: Codable, Equatable {
    public let id: String
    public let name: String
    public let runtime: Double
    public let budget: Double
    public let revenue: Double
    public let academyAwardNominations: Int
    public let academyAwardWins: Int
    public let score: Double
    public let posterURL: URL
    
    public init(id: String, name: String, runtime: Double, budget: Double, revenue: Double, academyAwardNominations: Int, academyAwardWins: Int, score: Double, posterURL: URL) {
        self.id = id
        self.name = name
        self.runtime = runtime
        self.budget = budget
        self.revenue = revenue
        self.academyAwardNominations = academyAwardNominations
        self.academyAwardWins = academyAwardWins
        self.score = score
        self.posterURL = posterURL
    }
}

