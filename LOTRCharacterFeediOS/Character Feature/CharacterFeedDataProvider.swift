//
//  CharacterFeedDataProvider.swift
//  LOTRCharacterFeediOS
//
//  Created by mohammadreza on 1/4/23.
//

import Foundation
import LOTRCharacterFeed

public class CharacterFeedDataProvider<L: Loader>: ObservableObject where L.Resource == [CharacterItem] {
    @Published var items: [CharacterFeedViewModel] = []
    
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
                        return CharacterFeedViewModel(id: $0.id, name: $0.name, race: $0.race, imageURL: $0.imageURL)
                    }
                } catch {
                    self.isErrorPresented = true
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
