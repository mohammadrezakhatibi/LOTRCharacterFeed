//
//  CharacterFeedDataProvider.swift
//  LOTRCharacterFeediOS
//
//  Created by mohammadreza on 1/4/23.
//

import Foundation
import LOTRCharacterFeed

public class CharacterFeedDataProvider: ObservableObject {
    @Published var items: [CharacterFeedViewModel] = []
    
    @Published var isErrorPresented = false
    @Published var errorMessage = ""
    
    private let loader: CharacterLoader
    
    public init(loader: CharacterLoader) {
        self.loader = loader
    }
    
    public func load() {
        loader.load { [weak self] result in
            guard let self else { return }
            do {
                self.items = try result.get().map {
                    return CharacterFeedViewModel(
                        id: $0.id,
                        name: $0.name,
                        race: $0.race,
                        birth: $0.birth,
                        realm: $0.realm,
                        imageURL: $0.imageURL)
                }
            } catch {
                self.isErrorPresented = true
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
