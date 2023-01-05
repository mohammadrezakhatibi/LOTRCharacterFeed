//
//  MainQueueDispatchDecorator.swift
//  LOTRApp
//
//  Created by mohammadreza on 1/5/23.
//

import Foundation
import LOTRCharacterFeed

final class MainQueueDispatchDecorator<T> {
    let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            return DispatchQueue.main.async { completion() }
        }
        completion()
    }
}

extension MainQueueDispatchDecorator: CharacterLoader where T: CharacterLoader {
    func load(completion: @escaping (CharacterLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
