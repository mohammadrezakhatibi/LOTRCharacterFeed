//
//  RemoteRequest.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/31/22.
//

import Foundation

public protocol RemoteRequest {
    var url: URL { get }
    var body: Data? { get }
    var header: [String: String]? { get }
    var method: String { get }
    
    func create() -> URLRequest
}

extension RemoteRequest {
    public var body: Data? {
        return nil
    }
    
    public var header: [String: String]? {
        return nil
    }
    
    public var method: String {
        return "GET"
    }
}
