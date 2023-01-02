//
//  CharacterFeedErrorViewModel.swift
//  LOTRCharacterFeediOS
//
//  Created by Mohammadreza on 1/2/23.
//

import Foundation


class CharacterFeedErrorViewModel: ObservableObject {
    @Published var isErrorPresented = false
    @Published var errorMessage = ""
}
