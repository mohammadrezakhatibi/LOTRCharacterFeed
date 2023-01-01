//
//  LOTRCharacterFeediOSTests.swift
//  LOTRCharacterFeediOSTests
//
//  Created by Mohammadreza on 1/1/23.
//

import XCTest
import SwiftUI
import ViewInspector
import LOTRCharacterFeed
import LOTRCharacterFeediOS

struct CharacterFeed: View {
    let loader: CharacterLoader
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    init(loader: CharacterLoader) {
        self.loader = loader
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                
            }
        }
    }
}

final class LOTRCharacterFeediOSTests: XCTestCase {
    
    func test_init_createsAList() throws {
        let loader = CharacterLoaderStub(result: .success([]))
        let sut = CharacterFeed(loader: loader)
        XCTAssertNoThrow(try sut.inspect().scrollView().lazyVGrid())
    }
    
    // MARK: - Helper
    private final class CharacterLoaderStub: CharacterLoader {
                
        private let result: CharacterLoader.Result
        
        init(result: CharacterLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (CharacterLoader.Result) -> Void) {
            completion(result)
        }
    }
}
