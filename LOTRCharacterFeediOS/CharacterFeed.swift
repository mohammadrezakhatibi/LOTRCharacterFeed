//
//  CharacterFeed.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/1/23.
//

import SwiftUI
import LOTRCharacterFeed

struct CharacterFeed: View {
    private let loader: CharacterLoader
    public var didAppear: ((Self) -> Void)?
    @State var characters: [CharacterItem] = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    init(loader: CharacterLoader) {
        self.loader = loader
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(characters, id: \.id) { character in
                    CharacterRow(character: character)
                }
            }
        }
        .onAppear {
            loadCharacters()
            didAppear?(self)
        }
    }
    
    private func loadCharacters() {
        loader.load { result in
            characters = try! result.get()
        }
    }
}

struct CharacterFeed_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
