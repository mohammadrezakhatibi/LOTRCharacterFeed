//
//  BookItem.swift
//  LOTRCharacterFeed
//
//  Created by mohammadreza on 2/22/23.
//

import Foundation

public struct BookItem: Codable, Equatable {
    public let id: String
    public let name: String
    public let publisher: String
    public let ISBN13: String
    public let coverURL: URL
    
    public init(id: String, name: String, publisher: String, ISBN13: String, coverURL: URL) {
        self.id = id
        self.name = name
        self.publisher = publisher
        self.ISBN13 = ISBN13
        self.coverURL = coverURL
    }
}
