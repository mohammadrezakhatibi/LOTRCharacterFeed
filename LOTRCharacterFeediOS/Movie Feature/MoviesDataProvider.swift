//
//  MoviesDataProvider.swift
//  LOTRCharacterFeediOS
//
//  Created by mohammadreza on 2/22/23.
//

import Foundation
import LOTRCharacterFeed

public class MoviesDataProvider<L: Loader>: ObservableObject where L.Resource == [MovieItem] {
    @Published var items: [MovieFeedViewModel] = []
    
    @Published var isErrorPresented = false
    @Published var errorMessage = ""
    
    private let loader: L
    
    public init(loader: L) {
        self.loader = loader
    }
    
    public func load() {
        loader.load { [weak self] result in
            guard let self else { return }
            DispatchQueue.main.async {
                do {
                    self.items = try result.get().map {
                        return MovieFeedViewModel(id: $0.id, name: $0.name, revenue: self.priceFormatter($0.boxOfficeRevenueInMillions), rate: "\($0.rottenTomatoesScore)", time: "\($0.runtimeInMinutes) Minutes", imageURL: $0.posterURL)
                    }
                } catch {
                    self.isErrorPresented = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func priceFormatter(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.maximumFractionDigits = 0
        
        let nsNumber = NSNumber(value: price)
        return "\(formatter.string(from: nsNumber) ?? "0") Millions"
    }
}
