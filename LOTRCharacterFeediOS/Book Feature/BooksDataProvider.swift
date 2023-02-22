import Foundation
import LOTRCharacterFeed

public class BooksDataProvider<L: Loader>: ObservableObject where L.Resource == [BookItem] {
    @Published var items: [BookViewModel] = []
    
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
                        return BookViewModel(id: $0.id, name: $0.name, publisher: $0.publisher, ISBN13: $0.ISBN13, coverURL: $0.coverURL)
                    }
                } catch {
                    self.isErrorPresented = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
