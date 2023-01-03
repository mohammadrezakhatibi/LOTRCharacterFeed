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
                if row.count >= items.count {
                    XCTAssertEqual(try row[index].find(viewWithId: 1).text().string(), item.name)
                    XCTAssertEqual(try row[index].find(viewWithId: 2).text().string(), item.race)
                    XCTAssertNotNil(try row[index].find(viewWithId: 3).asyncImage())
                    XCTAssertNotNil(try row[index].find(viewWithId: 3).asyncImage().url()?.absoluteString, item.imageURL.absoluteString)
                    XCTAssertNotNil(try row[index].find(viewWithId: 4).linearGradient())
                }
            }
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadCharacter_doesNotShowErrorOnSuccessfulLoadCharacters() throws {
        let items = makeItems()
        var sut = makeSUT(result: .success(items))
        
        let exp = sut.on(\.didAppear) { view in
            XCTAssertEqual(try view.actualView().errorModel.isErrorPresented, false)
            XCTAssertEqual(try view.actualView().errorModel.errorMessage, "")
            XCTAssertThrowsError(try view.scrollView().alert())
            XCTAssertThrowsError(try view.scrollView().alert().title().string())
            XCTAssertThrowsError(try view.scrollView().alert().message().text().string())
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadCharacter_showsErrorOnFailureLoadCharacters() throws {
        let error = NSError(domain: "an error", code: 0)
        var sut = makeSUT(result: .failure(error))
        
        let exp = sut.on(\.didAppear) { view in
            XCTAssertEqual(try view.actualView().errorModel.isErrorPresented, true)
            XCTAssertEqual(try view.actualView().errorModel.errorMessage, error.localizedDescription)
            XCTAssertNotNil(try view.scrollView().alert())
            XCTAssertEqual((try view.scrollView().alert().title().string()), "Error")
            XCTAssertEqual((try view.scrollView().alert().message().text().string()), error.localizedDescription)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper
    
    private func makeSUT(result: CharacterLoader.Result = .success([]), file: StaticString = #filePath, line: UInt = #line) -> CharacterFeed {
        let loader = CharacterLoaderStub(result: result)
        
        var sut = CharacterFeed()
        let interactor = CharacterFeedInteractor()
        let presenter = CharacterFeedPresenter()

        let worker = RemoteCharacterWorker(loader: loader)
        interactor.worker = worker
        sut.interactor = interactor
        interactor.presenter = presenter
        presenter.view = sut
        
        trackingForMemoryLeaks(loader, file: file, line: line)
        trackingForMemoryLeaks(interactor, file: file, line: line)
        trackingForMemoryLeaks(presenter, file: file, line: line)
        trackingForMemoryLeaks(worker, file: file, line: line)
        
        return sut
    }
    
    private func makeItems() -> [CharacterItem] {
        return [
            CharacterItem(id: "id", height: "", race: "human", gender: "", birth: "", spouse: "", death: "", realm: "", hair: "", name: "Frodo", wikiURL: nil, imageURL: URL(string: "https://any-url.com")!),
            CharacterItem(id: "id", height: "", race: "elf", gender: "", birth: "", spouse: "", death: "", realm: "", hair: "", name: "Aragorn", wikiURL: nil, imageURL: URL(string: "https://another-url.com")!)
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
