//
//  MockRequest.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/31/22.
//

import Foundation
import LOTRCharacterFeed

class MockRequest: RemoteRequest {
    var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func create() -> URLRequest {
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = header
        request.httpMethod = method
        return request
    }
    
}
