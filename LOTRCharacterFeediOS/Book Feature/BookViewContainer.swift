import SwiftUI
import Foundation
import LOTRCharacterFeed

public struct BookViewContainer<L: Loader>: View where L.Resource == [BookItem] {
    public var didAppear: ((Self) -> Void)?
    @ObservedObject var viewModel: BooksDataProvider<L>
    
    public init(viewModel: BooksDataProvider<L>) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        BookFeedView(items: viewModel.items)
        .onAppear {
            loadCharacters()
            didAppear?(self)
        }
        .alert("Error", isPresented: $viewModel.isErrorPresented, actions: {
            Button("OK", role: .cancel) {
                viewModel.isErrorPresented = false
                viewModel.errorMessage = ""
            }
        }, message: {
            Text(viewModel.errorMessage)
        })
    }
    
    private func loadCharacters() {
        viewModel.load()
    }
}
