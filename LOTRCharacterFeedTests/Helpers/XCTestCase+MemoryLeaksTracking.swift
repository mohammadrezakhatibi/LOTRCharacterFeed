//
//  XCTestCase+MemoryLeaksTracking.swift
//  LOTRCharacterFeedTests
//
//  Created by Mohammadreza on 12/24/22.
//

import XCTest

extension XCTestCase {
    func trackingForMemoryLeaks(_ instance: AnyObject,
                                file: StaticString = #filePath,
                                line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Potential memory leak on \(String(describing: instance))", file: file, line: line)
        }
    }
}
