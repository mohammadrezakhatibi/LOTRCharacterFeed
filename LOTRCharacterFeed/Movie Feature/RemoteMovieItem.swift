import Foundation

struct RemoteMovieItem: Codable {
    public let _id: String
    public let name: String
    public let runtimeInMinutes: Double
    public let budgetInMillions: Double
    public let boxOfficeRevenueInMillions: Double
    public let academyAwardNominations: Int
    public let academyAwardWins: Int
    public let rottenTomatoesScore: Double
    public let posterURL: URL
    
    public init(_id: String, name: String, runtimeInMinutes: Double, budgetInMillions: Double, boxOfficeRevenueInMillions: Double, academyAwardNominations: Int, academyAwardWins: Int, rottenTomatoesScore: Double, posterURL: URL) {
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
