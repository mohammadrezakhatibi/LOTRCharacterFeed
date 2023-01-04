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
        
        let exp = sut.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            self.render(view, for: items)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadCharacter_doesNotShowErrorOnSuccessfulLoadCharacters() throws {
        let items = makeItems()
        var sut = makeSUT(result: .success(items))
        
        let exp = sut.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            self.hideErrorAlert(in: view)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadCharacter_showsErrorOnFailureLoadCharacters() throws {
        let anyError = NSError(domain: "an error", code: 0)
        var sut = makeSUT(result: .failure(anyError))
        
        let exp = sut.on(\.didAppear) { [weak self] view in
            guard let self else { return }
            self.renderErrorAlert(in: view, with: anyError)
            try view.scrollView().alert().actions().first?.button().tap()
            self.hideErrorAlert(in: view)
        }
        
        ViewHosting.host(view: sut)
        wait(for: [exp], timeout: 1.0)
    }
    
    // MARK: - Helper
    
    private func makeSUT(result: CharacterLoader.Result = .success([]), file: StaticString = #filePath, line: UInt = #line) -> CharacterFeed {
        
        let loader = CharacterLoaderStub(result: result)
        let vm = CharacterFeedDataProvider(loader: loader)
        let sut = CharacterFeed(viewModel: vm)
        
        trackingForMemoryLeaks(loader, file: file, line: line)
        trackingForMemoryLeaks(vm, file: file, line: line)
        
        return sut
    }
    
    private func render(_ view: InspectableView<ViewType.View<CharacterFeed>>, for items: [CharacterItem]) {
        let row = view.findAll(CharacterRow.self)
        try? items.enumerated().forEach { index, item in
            guard row.count == items.count else {
                XCTFail("Couldn't find any rows")
                return
            }
            XCTAssertEqual(try row[index].find(viewWithId: 1).text().string(), item.name)
            XCTAssertEqual(try row[index].find(viewWithId: 2).text().string(), item.race)
            XCTAssertNotNil(try row[index].find(viewWithId: 3).asyncImage())
            XCTAssertNotNil(try row[index].find(viewWithId: 3).asyncImage().url()?.absoluteString, item.imageURL.absoluteString)
            XCTAssertNotNil(try row[index].find(viewWithId: 4).linearGradient())
            
        }
    }
    
    private func hideErrorAlert(in view: InspectableView<ViewType.View<CharacterFeed>>) {
        XCTAssertEqual(try view.actualView().viewModel.isErrorPresented, false)
        XCTAssertEqual(try view.actualView().viewModel.errorMessage, "")
        XCTAssertThrowsError(try view.scrollView().alert())
        XCTAssertThrowsError(try view.scrollView().alert().title().string())
        XCTAssertThrowsError(try view.scrollView().alert().message().text().string())
    }
    
    private func renderErrorAlert(in view: InspectableView<ViewType.View<CharacterFeed>>, with error: Error) {
        XCTAssertEqual(try view.actualView().viewModel.isErrorPresented, true)
        XCTAssertEqual(try view.actualView().viewModel.errorMessage, error.localizedDescription)
        XCTAssertNotNil(try view.scrollView().alert())
        XCTAssertEqual((try view.scrollView().alert().title().string()), "Error")
        XCTAssertEqual((try view.scrollView().alert().message().text().string()), error.localizedDescription)
    }
    
    private func makeItems() -> [CharacterItem] {
        return [
            CharacterItem(id: "id",
                          height: "1.20 cm",
                          race: "human",
                          gender: "",
                          birth: "600 BC",
                          spouse: "",
                          death: "719 BC",
                          realm: "Habitland",
                          hair: "Brown",
                          name: "Frodo",
                          wikiURL: nil,
                          imageURL: URL(string: "https://any-url.com")!),
            
            CharacterItem(id: "id",
                          height: "2.20 cm",
                          race: "elf",
                          gender: "",
                          birth: "",
                          spouse: "75 BC",
                          death: "850 BC",
                          realm: "Gondor",
                          hair: "Black",
                          name: "Aragorn",
                          wikiURL: nil,
                          imageURL: URL(string: "https://another-url.com")!)
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
