//
//  HTTPClient.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/23/22.
//

import Foundation

public protocol HTTPClientTask {
    func cancel()
}

public protocol HTTPClient {
    typealias Result = Swift.Result<(Data, HTTPURLResponse), Error>
    
    @discardableResult
    func get(from request: Request, completion: @escaping (Result) -> Void) -> HTTPClientTask
}


public protocol Request {
    var url: URL { get }
    var body: Data? { get }
    var header: [String: String]? { get }
}
