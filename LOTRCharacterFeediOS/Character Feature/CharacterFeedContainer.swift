import SwiftUI
import LOTRCharacterFeed

public struct CharacterFeedViewContainer<L: Loader>: View where L.Resource == [CharacterItem] {
    
    public var didAppear: ((Self) -> Void)?
    @ObservedObject var viewModel: CharacterFeedDataProvider<L>
    
    public init(viewModel: CharacterFeedDataProvider<L>) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        CharacterFeedView(items: viewModel.items)
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

