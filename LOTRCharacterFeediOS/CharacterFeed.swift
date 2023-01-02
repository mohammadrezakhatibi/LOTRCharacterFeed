//
//  CharacterFeed.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/1/23.
//

import SwiftUI
import LOTRCharacterFeed

class FeedDataSource: ObservableObject {
    @Published var items: [CharacterFeedViewModel] = []
}
struct CharacterFeed: View {
    var interactor: CharacterFeedBusinessLogic?
    public var didAppear: ((Self) -> Void)?
    var datas = FeedDataSource()
    @ObservedObject var error = CharacterFeedErrorViewModel()
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(datas.items, id: \.id) { character in
                    CharacterRow(character: character)
                }
            }
        }
        .onAppear {
            loadCharacters()
            didAppear?(self)
        }
        .alert("Error", isPresented: $error.isErrorPresented, actions: {
            Button("OK", role: .cancel) { }
        }, message: {
            Text(error.errorMessage)
        })
    }
    
    private func loadCharacters() {
        interactor?.loadItems()
    }
}

struct CharacterFeed_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
