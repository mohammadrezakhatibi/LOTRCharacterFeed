//
//  SharedTestHelpers.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/24/22.
//

import Foundation

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

func anyNSError() -> NSError {
    return NSError(domain: "an error", code: 0)
}

func anyData() -> Data {
    return Data("a data".utf8)
}
