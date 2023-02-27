import Foundation
import LOTRCharacterFeed

public class BooksFeedDataProvider: ObservableObject {
    @Published var items: [BookFeedViewModel] = []
    
    @Published var isErrorPresented = false
    @Published var errorMessage = ""
    
    private let loader: BooksLoader
    
    public init(loader: BooksLoader) {
        self.loader = loader
    }
    
    public func load() {
        loader.load { [weak self] result in
            guard let self else { return }
            do {
                self.items = try result.get().map {
                    return BookFeedViewModel(
                        id: $0.id,
                        name: $0.name,
                        publisher: $0.publisher,
                        barcode: $0.barcode,
                        imageURL: $0.coverURL)
                }
            } catch {
                self.isErrorPresented = true
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
