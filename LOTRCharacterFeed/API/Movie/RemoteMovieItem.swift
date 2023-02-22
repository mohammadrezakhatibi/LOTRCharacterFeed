import Foundation

public struct RemoteMovieItem: Codable {
    public var _id: String
    public var name: String
    public var runtimeInMinutes: Double
    public var budgetInMillions: Double
    public var boxOfficeRevenueInMillions: Double
    public var academyAwardNominations: Double
    public var academyAwardWins: Double
    public var rottenTomatoesScore: Double
    public var posterURL: URL
    
    public init(_id: String, name: String, runtimeInMinutes: Double, budgetInMillions: Double, boxOfficeRevenueInMillions: Double, academyAwardNominations: Double, academyAwardWins: Double, rottenTomatoesScore: Double, posterURL: URL) {
        self._id = _id
        self.name = name
        self.runtimeInMinutes = runtimeInMinutes
        self.budgetInMillions = budgetInMillions
        self.boxOfficeRevenueInMillions = boxOfficeRevenueInMillions
        self.academyAwardNominations = academyAwardNominations
        self.academyAwardWins = academyAwardWins
        self.rottenTomatoesScore = rottenTomatoesScore
        self.posterURL = posterURL
    }
}
