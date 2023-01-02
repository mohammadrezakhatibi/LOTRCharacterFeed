//
//  VocabulariesListDisplayLogic.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/2/23.
//

import Foundation

protocol CharacterFeedDisplayLogic {
    func displayCharactersFeed(viewModel: CharacterFeedModel.LoadCharacters.ViewModel)
    func displayError(with error: Error)
}

extension CharacterFeed: CharacterFeedDisplayLogic {
    func displayCharactersFeed(viewModel: CharacterFeedModel.LoadCharacters.ViewModel) {
        datas.items = viewModel.feedViewModel
    }
    
    func displayError(with error: Error) {
        self.error.isErrorPresented = true
        self.error.errorMessage = error.localizedDescription
    }
}
