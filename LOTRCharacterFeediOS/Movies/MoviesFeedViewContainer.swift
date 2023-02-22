import SwiftUI
import LOTRCharacterFeed

public struct MoviesFeedViewContainer: View {
    
    public var didAppear: ((Self) -> Void)?
    @ObservedObject var viewModel: MoviesFeedDataProvider
    
    public init(viewModel: MoviesFeedDataProvider) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        MovieFeedView(items: viewModel.items)
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

