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
