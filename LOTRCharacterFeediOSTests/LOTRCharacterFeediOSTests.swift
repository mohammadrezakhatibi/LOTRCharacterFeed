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
@testable import LOTRCharacterFeediOS

final class LOTRCharacterFeediOSTests: XCTestCase {
    
    func test_init_createsAList() throws {
        let sut = makeSUT()
        XCTAssertNoThrow(try sut.inspect().scrollView().lazyVGrid())
    }

    func test_loadCharacter_deliversAListOfCharacters() throws {
        let items = makeItems()
        var sut = makeSUT(result: .success(items))
        
        let exp = sut.on(\.didAppear) { view in
            let cells = view.findAll(CharacterRow.self)
            XCTAssertEqual(cells.count, items.count)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadCharacter_displaysCharacterNameAndRaceOnSuccessfulLoadCharacter() throws {
        
        let items = makeItems()
        var sut = makeSUT(result: .success(items))
        
        let exp = sut.on(\.didAppear) { view in
            let row = view.findAll(CharacterRow.self)
            try items.enumerated().forEach { index, item in
                XCTAssertEqual(try row[index].find(viewWithId: 1).text().string(), item.name)
                XCTAssertEqual(try row[index].find(viewWithId: 2).text().string(), item.race)
                XCTAssertNotNil(try row[index].find(viewWithId: 3).asyncImage())
                XCTAssertNotNil(try row[index].find(viewWithId: 4).linearGradient())
            }
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper
    
    private func makeSUT(result: CharacterLoader.Result = .success([])) -> CharacterFeed {
        let loader = CharacterLoaderStub(result: result)
        let sut = CharacterFeed(loader: loader)
        
        return sut
    }
    
    private func makeItems() -> [CharacterItem] {
        return [
            CharacterItem(id: "id", height: "", race: "human", gender: "", birth: "", spouse: "", death: "", realm: "", hair: "", name: "Frodo", wikiURL: nil, imageURL: URL(string: "https://any-url.com")!),
            CharacterItem(id: "id", height: "", race: "elf", gender: "", birth: "", spouse: "", death: "", realm: "", hair: "", name: "Aragorn", wikiURL: nil, imageURL: URL(string: "https://any-url.com")!)
        ]
    }
    
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
