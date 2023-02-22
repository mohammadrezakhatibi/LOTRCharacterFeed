//
//  MovieViewContainer.swift
//  LOTRCharacterFeediOS
//
//  Created by mohammadreza on 2/22/23.
//

import SwiftUI
import LOTRCharacterFeed

public struct MovieViewContainer<L: Loader>: View where L.Resource == [MovieItem] {
    public var didAppear: ((Self) -> Void)?
    @ObservedObject var viewModel: MoviesDataProvider<L>
    
    public init(viewModel: MoviesDataProvider<L>) {
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
