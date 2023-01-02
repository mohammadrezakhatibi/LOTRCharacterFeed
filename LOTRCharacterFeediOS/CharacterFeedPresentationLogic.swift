//
//  CharacterFeedPresentationLogic.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/2/23.
//

import Foundation

protocol CharacterFeedPresentationLogic {
    func presentCharacterFeed(response: CharacterFeedModel.LoadCharacters.Response)
    func presentErrorView(with error: Error)
}

class CharacterFeedPresenter {
    var view: CharacterFeedDisplayLogic?
}

extension CharacterFeedPresenter: CharacterFeedPresentationLogic {
    func presentCharacterFeed(response: CharacterFeedModel.LoadCharacters.Response) {
        let model = response.characters.map {
            return CharacterFeedViewModel(id: $0.id, name: $0.name, race: $0.race, imageURL: $0.imageURL)
        }
        let viewModel = CharacterFeedModel.LoadCharacters.ViewModel(feedViewModel: model)
        
        view?.displayCharactersFeed(viewModel: viewModel)
    }
    
    func presentErrorView(with error: Error) {
        view?.displayError(with: error)
    }
}
