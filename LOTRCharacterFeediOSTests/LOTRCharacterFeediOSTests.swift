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
    private let loader: CharacterLoader
    public var didAppear: ((Self) -> Void)?
    @State var characters: [CharacterItem] = []
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]
    
    init(loader: CharacterLoader) {
        self.loader = loader
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(characters, id: \.id) { character in
                    CharacterRow(character: character)
                }
            }
        }
        .onAppear {
            loadCharacters()
            didAppear?(self)
        }
    }
    
    private func loadCharacters() {
        loader.load { result in
            characters = try! result.get()
        }
    }
}

struct CharacterRow: View {
    private(set) var character: CharacterItem
    
    public var body: some View {
        return VStack {
            ZStack(alignment: .bottomLeading) {
                Rectangle()
                    .overlay {
                        ZStack(alignment: .topLeading) {
                            AsyncImage(url: character.imageURL) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .clipped()
                            } placeholder: {
                                
                            }
                            .id(3)
                    }
                    .foregroundColor(.black)
                    .frame(minHeight: 240)
                    .cornerRadius(16)
                
                LinearGradient(gradient: Gradient(colors: [.black.opacity(0.5), .white.opacity(0)]), startPoint: .bottom, endPoint: .top)
                    .cornerRadius(16)
                    .clipped()
                    .id(4)
                
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    Text(character.name)
                        .id(1)
                        .font(.title)
                        .fontDesign(.serif)
                        .foregroundColor(.white)
                        .padding(.bottom, 4)
                    HStack(alignment: .center) {
                        Image("species")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .scaledToFill()
                            .clipped()
                        Text(character.race)
                            .foregroundColor(.yellow)
                            .font(.body)
                            .id(2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .clipped()
        }
        }
    }
}

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
