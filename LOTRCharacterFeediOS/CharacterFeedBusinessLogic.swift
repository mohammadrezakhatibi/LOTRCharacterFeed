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

protocol CharacterFeedWorker {
    func loadCharacters(completion: @escaping (CharacterLoader.Result) -> Void)
}

final class RemoteCharacterWorker: CharacterFeedWorker {
    
    let loader: CharacterLoader
    
    init(loader: CharacterLoader) {
        self.loader = loader
    }
    
    func loadCharacters(completion: @escaping (CharacterLoader.Result) -> Void) {
        loader.load(completion: completion)
    }
}

enum CharacterFeedModel {
    enum LoadCharacters {
        struct Request { }
        
        struct Response {
            var characters: [CharacterItem]
        }
        
        struct ViewModel {
            var feedViewModel: [CharacterFeedViewModel]
        }
    }
}

struct CharacterFeedViewModel {
    let id: String
    let name: String
    let race: String
    let imageURL: URL
}
