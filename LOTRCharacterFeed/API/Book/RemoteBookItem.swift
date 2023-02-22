//
//  RemoteBookItem.swift
//  LOTRCharacterFeed
//
//  Created by mohammadreza on 2/22/23.
//

import Foundation
public struct RemoteBookItem: Codable {
    public var _id: String
    public var name: String
    public let publisher: String
    public let ISBN13: String
    public var coverURL: URL
    
    public init(_id: String, name: String, publisher: String, ISBN13: String, coverURL: URL) {
        self._id = _id
        self.name = name
        self.publisher = publisher
        self.ISBN13 = ISBN13
        self.coverURL = coverURL
    }
}
