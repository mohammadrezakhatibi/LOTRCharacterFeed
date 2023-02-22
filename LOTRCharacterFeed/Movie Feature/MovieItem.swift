//
//  MovieItem.swift
//  LOTRCharacterFeed
//
//  Created by mohammadreza on 2/22/23.
//

import Foundation

public struct MovieItem: Codable, Equatable {
    public let id: String
    public let name: String
    public let runtimeInMinutes: Double
    public let budgetInMillions: Double
    public let boxOfficeRevenueInMillions: Double
    public let academyAwardNominations: Double
    public let academyAwardWins: Double
    public let rottenTomatoesScore: Double
    public let posterURL: URL
    
    public init(id: String, name: String, runtimeInMinutes: Double, budgetInMillions: Double, boxOfficeRevenueInMillions: Double, academyAwardNominations: Double, academyAwardWins: Double, rottenTomatoesScore: Double, posterURL: URL) {
        self.id = id
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
