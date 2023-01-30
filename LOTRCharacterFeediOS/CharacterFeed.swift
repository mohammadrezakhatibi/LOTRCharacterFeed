//
//  CharacterFeed.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/1/23.
//

import SwiftUI
import LOTRCharacterFeed

public struct CharacterFeed: View {
    
    public var didAppear: ((Self) -> Void)?
    @ObservedObject var viewModel: CharacterFeedDataProvider
    private let imageLoader: CharacterImageDataLoader
    
    public init(viewModel: CharacterFeedDataProvider, imageLoader: CharacterImageDataLoader) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    public var body: some View {
        ScrollView {
            if (viewModel.items.isEmpty == true) {
                ProgressView()
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.items, id: \.id) { character in
                        CharacterRow(character: character, cacheLoader: imageLoader)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
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

struct CharacterFeed_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
