//
//  HTTPURLResponse+StatusCode.swift
//  LOTRCharacterFeed
//
//  Created by Mohammadreza on 12/23/22.
//

import Foundation

extension HTTPURLResponse {
    private static var OK_200: Int { return 200 }
    private static var unauthorized_400: Int { return 400 }
    
    var isOK: Bool {
        return statusCode == HTTPURLResponse.OK_200
    }
    
    var isUnauthorized: Bool {
        return statusCode == HTTPURLResponse.unauthorized_400
    }
}
