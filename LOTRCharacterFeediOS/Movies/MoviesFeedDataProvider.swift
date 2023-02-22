import Foundation
import LOTRCharacterFeed

public class MoviesFeedDataProvider: ObservableObject {
    @Published var items: [MovieFeedViewModel] = []
    
    @Published var isErrorPresented = false
    @Published var errorMessage = ""
    
    private let loader: MovieLoader
    
    public init(loader: MovieLoader) {
        self.loader = loader
    }
    
    public func load() {
        loader.load { [weak self] result in
            guard let self else { return }
            do {
                self.items = try result.get().map {
                    return MovieFeedViewModel(
                        id: $0.id,
                        name: $0.name,
                        revenue: "\($0.revenue)",
                        score: "\($0.score)",
                        runtime: "\($0.runtime)",
                        posterURL: $0.posterURL)
                }
            } catch {
                self.isErrorPresented = true
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
