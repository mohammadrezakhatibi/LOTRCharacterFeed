//
//  CharacterFeedView.swift
//  LOTRCharacterFeediOS
//
//  Created by mohammadreza on 2/21/23.
//

import SwiftUI

struct CharacterFeedView: View {
    public var items: [CharacterFeedViewModel]
    
    init(items: [CharacterFeedViewModel]) {
        self.items = items
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 16),
    ]
    private let columnsOne = [
        GridItem(.flexible(), spacing: 16),
    ]
    var body: some View {
        ScrollView {
            if (items.isEmpty == true) {
                ProgressView()
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(items, id: \.id) { character in
                        CharacterRow(character: character)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
struct CharacterFeedView_Previews: PreviewProvider {
    static var previews: some View {
        let mockCharacters = [
            CharacterFeedViewModel(id: UUID().uuidString, name: "Aragorn II Elessar", race: "Human", birth: "March 1 ,2931", realm: "eunited Kingdom,Arnor,Gondor", imageURL: URL(string: "https://lokomond.com/lotr/characters/images/Aragorn_II_Elessar.jpg")!),
            CharacterFeedViewModel(id: UUID().uuidString, name: "Frodo Baggins", race: "Hobbit", birth: "22 September ,TA 2968", realm: "Various", imageURL: URL(string: "https://lokomond.com/lotr/characters/images/Frodo_Baggins.jpg")!),
        ]
        Group {
            CharacterFeedView(items: mockCharacters)
            .previewLayout(.fixed(width: 400, height: 300))
            .previewDisplayName("Character Feed With Items - Two column")
            
            CharacterFeedView(items: mockCharacters)
            .previewLayout(.fixed(width: 400, height: 600))
            .previewDisplayName("Character Feed With Items - One column")
            .environment(\.sizeCategory, .accessibilityExtraLarge)
            
            CharacterFeedView(items: [])
            .previewLayout(.fixed(width: 400, height: 300))
            .previewDisplayName("Character Feed - No item")
        }
    }
}
