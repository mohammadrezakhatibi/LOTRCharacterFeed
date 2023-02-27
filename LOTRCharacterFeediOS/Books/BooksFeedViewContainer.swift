import SwiftUI
import LOTRCharacterFeed

public struct BooksFeedViewContainer: View {
    
    public var didAppear: ((Self) -> Void)?
    @ObservedObject var viewModel: BooksFeedDataProvider
    
    public init(viewModel: BooksFeedDataProvider) {
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

