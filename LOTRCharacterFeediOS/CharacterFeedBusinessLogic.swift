//
//  CharacterFeedBusinessLogic.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/2/23.
//
import Foundation
import LOTRCharacterFeed

protocol CharacterFeedBusinessLogic {
    func loadItems()
}

final class CharacterFeedInteractor {
    var presenter: CharacterFeedPresenter?
    var worker: CharacterFeedWorker?
}

extension CharacterFeedInteractor: CharacterFeedBusinessLogic {
    func loadItems() {
        worker?.loadCharacters { [weak self] result in
            guard let self else { return }
            do {
                let response = CharacterFeedModel.LoadCharacters.Response(characters: try result.get())
                self.presenter?.presentCharacterFeed(response: response)
            } catch {
                self.presenter?.presentErrorView(with: error)
            }
        }
    }
}
